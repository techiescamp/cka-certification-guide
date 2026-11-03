# Gateway API: HTTP and HTTPS lab

Run these commands from the repository root on a Linux Kubernetes cluster created for practice. You need Helm 3+, kubectl, curl, and an OpenSSL version that supports `-addext`.

This lab uses the repository's existing **NGINX Gateway Fabric 2.0.1** chart. It keeps the same controller and GatewayClass as the existing scenarios. Use a fresh practice cluster for this lab. Its GatewayClass and release names are also used by the existing scenarios, so do not run them together in a shared cluster.

## Controller and CRDs

Install Gateway API 1.3.0 CRDs before the controller, as in the existing scenarios. Do not downgrade CRDs in a shared cluster. See the [NGINX Gateway Fabric installation guide](https://docs.nginx.com/nginx-gateway-fabric/install/helm/) for the installation flow; this lab uses the versions already bundled in this repository.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
kubectl wait --for=condition=Established crd/gateways.gateway.networking.k8s.io crd/httproutes.gateway.networking.k8s.io --timeout=60s
helm upgrade --install ngf ./helm-charts/nginx-gateway-fabric -n nginx-gateway \
  --create-namespace --set nginx.service.type=ClusterIP --wait --timeout 5m
kubectl create namespace gateway-lab
kubectl -n gateway-lab create deployment web --image=nginx:stable
kubectl -n gateway-lab expose deployment web --port=80
kubectl -n gateway-lab rollout status deployment/web --timeout=180s
```

The chart creates the controller and an `NginxProxy` named `ngf-proxy-config`. The GatewayClass below refers to that configuration. NGINX Gateway Fabric creates a separate NGINX data-plane Deployment and Service for the Gateway. This lab uses a ClusterIP Service and port-forward, so it does not need a cloud load balancer.

## TLS and routing

Create a short-lived self-signed certificate in a temporary directory, then a TLS Secret in the same namespace as the Gateway:

```bash
CERT_DIR=$(mktemp -d)
openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
  -keyout "$CERT_DIR/tls.key" -out "$CERT_DIR/tls.crt" \
  -subj '/CN=app.example.com' -addext 'subjectAltName=DNS:app.example.com'
kubectl -n gateway-lab create secret tls app-tls \
  --cert="$CERT_DIR/tls.crt" --key="$CERT_DIR/tls.key"
kubectl apply -f lessons/gateway-api/http-https.yaml
kubectl wait --for=condition=Accepted gatewayclass/nginx-gateway-class --timeout=120s
kubectl -n gateway-lab wait --for=condition=Programmed gateway/web --timeout=120s
kubectl -n gateway-lab rollout status deployment/web-nginx-gateway-class --timeout=180s
kubectl -n gateway-lab get gateway web -o yaml
kubectl -n gateway-lab get httproute web -o yaml
```

Check the listener conditions and the status of each HTTPRoute parent. `Accepted` and `ResolvedRefs` should be True. Check that `observedGeneration` matches the resource’s current `metadata.generation`, so you know the status reflects your latest changes. The HTTP listener has no TLS block. HTTPS terminates TLS using `app-tls` and forwards HTTP to the backend. You do not need a ReferenceGrant when these resources are in the same namespace. See [Gateway API TLS configuration](https://gateway-api.sigs.k8s.io/guides/user-guides/tls/).

## Send requests

In a separate terminal, run:

```bash
# Find the Service created for Gateway "web".
kubectl -n gateway-lab get services
# Use that Service name (web-nginx-gateway-class in this lab).
kubectl -n gateway-lab port-forward service/web-nginx-gateway-class 8080:80 8443:443
```

In the original terminal (where `CERT_DIR` is set):

```bash
curl --fail -H 'Host: app.example.com' http://127.0.0.1:8080/
curl --fail --cacert "$CERT_DIR/tls.crt" \
  --resolve app.example.com:8443:127.0.0.1 https://app.example.com:8443/
kubectl -n gateway-lab get endpointslices -l kubernetes.io/service-name=web -o yaml
```

Both requests should return the NGINX welcome page. `--resolve` sends the request to the local port while keeping the correct TLS server name. `--cacert` tells curl to trust your test certificate and still check it. If routing fails, inspect Gateway/HTTPRoute conditions, Secret name, Service port, EndpointSlice readiness, and controller logs with `kubectl -n nginx-gateway logs deployment/ngf-nginx-gateway-fabric`.

## Cleanup

Stop port-forward with Ctrl+C. In the original terminal, remove the lab resources. Uninstall the controller only if you installed it for this lab and no other Gateways use it:

```bash
kubectl delete -f lessons/gateway-api/http-https.yaml
kubectl delete namespace gateway-lab
helm uninstall ngf -n nginx-gateway
kubectl delete namespace nginx-gateway
rm -f "$CERT_DIR/tls.key" "$CERT_DIR/tls.crt"
rmdir "$CERT_DIR"
```

Keep cluster-wide Gateway API CRDs if any other controller uses them. On an otherwise empty practice cluster, remove the lab-installed CRDs with:

```bash
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
```
