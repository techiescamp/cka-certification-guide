# EndpointSlice troubleshooting lab

Use a new practice namespace on a working cluster. The [EndpointSlice API](https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/) is the primary source of Service backend addresses, ports, and readiness. The legacy Endpoints API is deprecated since v1.33.

```bash
kubectl create namespace slices-lab
kubectl -n slices-lab create deployment web --image=nginx:stable
kubectl -n slices-lab rollout status deployment/web --timeout=180s
kubectl -n slices-lab expose deployment web --port=80 --target-port=80
kubectl -n slices-lab get endpointslices -l kubernetes.io/service-name=web -o yaml
kubectl -n slices-lab get service web -o yaml
kubectl -n slices-lab get pods -o wide --show-labels
```

Compare every slice's `endpoints[].addresses` with Pod IPs, `ports[].port` with the listening backend port, and `endpoints[].conditions.ready` with Pod readiness. Selectors must match Pod labels in the Service's namespace.

## Break and repair the selector

```bash
kubectl -n slices-lab patch service web -p '{"spec":{"selector":{"app":"wrong"}}}'
kubectl -n slices-lab get endpointslices -l kubernetes.io/service-name=web -o yaml
kubectl -n slices-lab patch service web -p '{"spec":{"selector":{"app":"web"}}}'
```

After Kubernetes processes the change, the wrong selector leaves no matching backend addresses. After repair, wait for the ready address to return. Repeat the inspection commands and test connectivity:

```bash
kubectl -n slices-lab run client --image=busybox:1.37 --restart=Never \
  --rm -i -- wget -qO- http://web
```

Expect the NGINX welcome page. For a port exercise, edit the Service's `targetPort` to `8080`; inspect the EndpointSlice port and retry with `wget -T 5`. Addresses can exist even when the port is wrong. Restore `targetPort: 80`. If addresses exist but readiness is false, check `kubectl describe pod` and the application logs. Fix the Pod or Service instead of editing EndpointSlices that Kubernetes manages.

```bash
kubectl delete namespace slices-lab
```
