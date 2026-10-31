# Dynamic local-storage lab

Run these commands from the repository root on a Linux practice cluster. You need a Ready worker node and `kubectl` access. Install the [Rancher Local Path Provisioner](https://github.com/rancher/local-path-provisioner) release below if it is not already installed. Avoid installing a second copy over an existing installation.

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deployment/local-path-provisioner --timeout=180s
kubectl apply -f lessons/dynamic-storage/storage.yaml
kubectl -n storage-lab get pvc
```

The PVC starts in Pending state. `WaitForFirstConsumer` waits until Kubernetes schedules a Pod that uses the volume before creating storage. The `rancher.io/local-path` controller creates the backing directory and PV; `kubernetes.io/no-provisioner` would require you to create a PV manually.

```bash
kubectl apply -f lessons/dynamic-storage/pod.yaml
kubectl -n storage-lab wait --for=condition=Ready pod/writer --timeout=180s
kubectl -n storage-lab get pvc
kubectl get pv
kubectl -n storage-lab exec writer -- sh -c 'echo persistent > /data/check.txt'
kubectl -n storage-lab delete pod writer
kubectl apply -f lessons/dynamic-storage/pod.yaml
kubectl -n storage-lab wait --for=condition=Ready pod/writer --timeout=180s
kubectl -n storage-lab exec writer -- cat /data/check.txt
```

Expect `persistent` after recreating the Pod. If binding fails, inspect PVC/Pod events and provisioner logs. Node affinity ties the volume to its original node. The data is not copied to other nodes. This provisioner also does not enforce the requested size as a storage limit.

## Cleanup

Save the PV name before deleting the Pod and PVC:

```bash
PV_NAME=$(kubectl -n storage-lab get pvc data -o jsonpath='{.spec.volumeName}')
kubectl delete -f lessons/dynamic-storage/pod.yaml
kubectl delete -f lessons/dynamic-storage/storage.yaml
kubectl wait --for=delete "pv/$PV_NAME" --timeout=180s
```

With `Delete`, the provisioner removes the stored data and the PV. Keep it running until this cleanup finishes. Uninstall it only if you installed it for this lab and no other volumes use it:

```bash
kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.37/deploy/local-path-storage.yaml
```
