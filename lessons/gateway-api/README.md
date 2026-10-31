# Gateway API: HTTP and HTTPS lab

Run these commands from the repository root on a Linux Kubernetes cluster created for practice. You need Helm 3+, kubectl, curl, and an OpenSSL version that supports `-addext`. This lab uses Traefik. It does not need the older NGINX Gateway Fabric scenarios in this directory. Use a cluster without another Traefik Gateway controller to avoid two controllers trying to manage the same GatewayClass.

## Controller and CRDs

The [Traefik Gateway provider documentation](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-gateway/) specifies the Standard-channel Gateway API CRDs. Install them before the controller:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml
kubectl wait --for=condition=Established crd/gateways.gateway.networking.k8s.io crd/httproutes.gateway.networking.k8s.io --timeout=60s
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install cka-gateway traefik/traefik --version 42.2.0 -n gateway-system \
  --create-namespace -f lessons/gateway-api/traefik-values.yaml --wait --timeout 5m
kubectl create namespace gateway-lab
kubectl -n gateway-lab create deployment web --image=nginx:stable
kubectl -n gateway-lab expose deployment web --port=80
kubectl -n gateway-lab rollout status deployment/web --timeout=180s
```

The values file makes Traefik listen on ports 80 and 443, matching the Gateway listeners. `NET_BIND_SERVICE` allows it to use these low port numbers without running as root. The lab uses a ClusterIP Service and port-forward, so you do not need a cloud load balancer. The chart creates the controller permissions (RBAC). You create the GatewayClass and Gateway in the next step.

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
kubectl wait --for=condition=Accepted gatewayclass/cka-traefik --timeout=120s
kubectl -n gateway-lab wait --for=condition=Programmed gateway/web --timeout=120s
kubectl -n gateway-lab get gateway web -o yaml
kubectl -n gateway-lab get httproute web -o yaml
```

Check the listener conditions and the status of each HTTPRoute parent. `Accepted` and `ResolvedRefs` should be True. Check that `observedGeneration` matches the resource’s current `metadata.generation`, so you know the status reflects your latest changes. The HTTP listener has no TLS block. HTTPS terminates TLS using `app-tls` and forwards HTTP to the backend. You do not need a ReferenceGrant when these resources are in the same namespace. See [Gateway API TLS configuration](https://gateway-api.sigs.k8s.io/guides/user-guides/tls/).

## Send requests

In a separate terminal, run:

```bash
kubectl -n gateway-system port-forward service/cka-gateway 8080:80 8443:443
```

In the original terminal (where `CERT_DIR` is set):

```bash
curl --fail -H 'Host: app.example.com' http://127.0.0.1:8080/
curl --fail --cacert "$CERT_DIR/tls.crt" \
  --resolve app.example.com:8443:127.0.0.1 https://app.example.com:8443/
kubectl -n gateway-lab get endpointslices -l kubernetes.io/service-name=web -o yaml
```

Both requests should return the NGINX welcome page. `--resolve` sends the request to the local port while keeping the correct TLS server name. `--cacert` tells curl to trust your test certificate and still check it. If routing fails, inspect Gateway/HTTPRoute conditions, Secret name, Service port, EndpointSlice readiness, and controller logs with `kubectl -n gateway-system logs deployment/cka-gateway`.

## Cleanup

Stop port-forward with Ctrl+C. In the original terminal:

```bash
kubectl delete -f lessons/gateway-api/http-https.yaml
kubectl delete namespace gateway-lab
helm uninstall cka-gateway -n gateway-system
kubectl delete namespace gateway-system
rm -f "$CERT_DIR/tls.key" "$CERT_DIR/tls.crt"
rmdir "$CERT_DIR"
```

Keep cluster-wide Gateway API CRDs if any other controller uses them. On an otherwise empty practice cluster, remove the lab-installed CRDs with:

```bash
kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml
```
