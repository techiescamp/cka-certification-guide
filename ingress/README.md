# Ingress lab with Traefik

Use a disposable cluster, Helm 3+, and kubectl. From the repository root:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install cka-ingress traefik/traefik --version 42.2.0 --namespace cka-ingress \
  --create-namespace --set providers.kubernetesIngress.enabled=true \
  --set ingressClass.name=traefik --set ingressClass.isDefaultClass=false \
  --set fullnameOverride=cka-ingress-traefik --set service.spec.type=ClusterIP --wait --timeout 5m
kubectl get ingressclass traefik
kubectl -n default create deployment webserver --image=nginx:stable
kubectl -n default expose deployment webserver --port=80
kubectl -n default rollout status deployment/webserver --timeout=180s
kubectl apply -f ingress/ingress.yaml
kubectl -n default get ingress webserver-ingress
kubectl -n cka-ingress port-forward service/cka-ingress-traefik 8080:80
```

In another terminal, run `curl -H 'Host: test.local' http://127.0.0.1:8080/`. The route forwards `/` to the `webserver` Service unchanged. Check backend readiness with `kubectl -n default get endpointslices -l kubernetes.io/service-name=webserver`.

This uses the maintained [Traefik Kubernetes controller](https://doc.traefik.io/traefik/setup/kubernetes/). The old `nginx-controller.yaml` and files under `scenarios/` are legacy exercises for community Ingress NGINX, which [retired in March 2026](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). Do not install that retired controller for this lab. NGINX Gateway Fabric is a different project.

Stop port-forward with Ctrl+C, then clean up the resources created here:

```bash
kubectl delete -f ingress/ingress.yaml
kubectl -n default delete deployment/webserver service/webserver
helm uninstall cka-ingress -n cka-ingress
kubectl delete namespace cka-ingress
```
