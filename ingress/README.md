# Ingress lab

This lab uses the F5 NGINX Ingress Controller. It supports the Kubernetes Ingress API. The Gateway API lab uses the NGINX Gateway Fabric. They handle different resource types.

Use a practice cluster and Helm 3.19 or later. From the repository root, install controller chart version 2.8.0. For a local cluster without a cloud load balancer, set the Service type to `ClusterIP`:

```bash
helm upgrade --install cka-ingress oci://ghcr.io/nginx/charts/nginx-ingress \
  --version 2.8.0 --namespace cka-ingress --create-namespace \
  --set controller.service.type=ClusterIP --wait --timeout 5m
kubectl -n cka-ingress get pods,services
kubectl get ingressclass nginx
kubectl -n default create deployment webserver --image=nginx:stable
kubectl -n default expose deployment webserver --port=80
kubectl -n default rollout status deployment/webserver --timeout=180s
kubectl apply -f ingress/ingress.yaml
kubectl -n default get ingress webserver-ingress
```

In a second terminal, use the Service name shown by `kubectl -n cka-ingress get services`:

```bash
kubectl -n cka-ingress port-forward service/<controller-service-name> 8080:80
```

Then send a request with the host from the Ingress rule:

```bash
curl -H 'Host: test.local' http://127.0.0.1:8080/
```

The response should show the NGINX welcome page. Check the backend addresses with `kubectl -n default get endpointslices -l kubernetes.io/service-name=webserver`.

The community Ingress NGINX project retired in March 2026. The F5 NGINX Ingress Controller in this lab is a separate project. The old `nginx-controller.yaml` manifest is kept for reference only; do not install it. See the [official Helm installation guide](https://docs.nginx.com/nginx-ingress-controller/install/helm/open-source/) and [basic Ingress guide](https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/basic-configuration/).

Stop port-forward with Ctrl+C. Then remove the lab resources:

```bash
kubectl delete -f ingress/ingress.yaml
kubectl -n default delete deployment/webserver service/webserver
helm uninstall cka-ingress -n cka-ingress
kubectl delete namespace cka-ingress
```

The chart also installs cluster-wide CRDs. Helm leaves them behind when the release is removed. On a disposable cluster, remove them only after checking that no other NGINX Ingress Controller or custom resources use them. Follow the [official CRD cleanup steps](https://docs.nginx.com/nginx-ingress-controller/install/helm/uninstall/); deleting these CRDs also deletes their custom resources across all namespaces.
