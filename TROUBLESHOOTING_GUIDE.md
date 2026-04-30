# Kubernetes Troubleshooting Guide 🔧

> Systematic debug playbooks for every layer of Kubernetes.
> Troubleshooting is **30% of the CKA exam** — master this section.

---

## The Universal Debug Checklist

Before diving deep into any issue, run this quick triage:

```bash
# 1. What's the resource state?
kubectl get <resource> -n <ns> -o wide

# 2. What do events say?
kubectl describe <resource> <name> -n <ns>

# 3. Are there logs?
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous   # if crashed

# 4. Any cluster-wide events?
kubectl get events -n <ns> --sort-by='.lastTimestamp'
```

---

## 1. Node Troubleshooting

### Node is `NotReady`

```bash
# Step 1: Check node conditions
kubectl describe node <node-name>
# Look for: MemoryPressure, DiskPressure, PIDPressure, NetworkUnavailable

# Step 2: Check kubelet on the node
ssh <node-name>
systemctl status kubelet

# Step 3: If kubelet is stopped
systemctl start kubelet
systemctl enable kubelet

# Step 4: Read kubelet logs for root cause
journalctl -u kubelet -f
journalctl -u kubelet --since "10 minutes ago" | grep -i error

# Step 5: Check for disk pressure
df -h
# If /var/lib/kubelet or /var/lib/docker is full → clean up

# Step 6: Check for memory pressure
free -m
top

# Step 7: Verify kubelet config
cat /var/lib/kubelet/config.yaml
cat /etc/kubernetes/kubelet.conf

# Step 8: Check certificates
openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -dates
```

### Node Taint Issues

```bash
# List node taints
kubectl describe node <node> | grep Taints

# Remove a taint
kubectl taint nodes <node> <key>=<value>:<effect>-

# Check if pods have matching tolerations
kubectl get pod <pod> -o yaml | grep -A10 tolerations
```

### Node Resource Pressure

```bash
# Check resource allocation
kubectl describe node <node> | grep -A5 "Allocated resources"
kubectl describe node <node> | grep -E "cpu|memory" | grep -v "^  "

# Top pods on a specific node
kubectl top pods -A --sort-by=cpu | grep <node>
```

---

## 2. Pod Troubleshooting

### Pod State Reference

| State | Root Cause Investigation |
|-------|-------------------------|
| `Pending` | No schedulable node: resources, taints, affinity, PVC |
| `ContainerCreating` | Image pull in progress, or stuck: volume/configmap issue |
| `Running` but not working | App bug, wrong config, probe failure |
| `CrashLoopBackOff` | App crash — check logs + exit code |
| `OOMKilled` | Memory limit too low |
| `ImagePullBackOff` | Wrong image name/tag or missing registry secret |
| `ErrImagePull` | Same as above, initial pull attempt |
| `Terminating` (stuck) | Finalizer blocking deletion |
| `Error` | Init container or container command failure |
| `Evicted` | Node under disk/memory pressure |

### Diagnose by Exit Code

```bash
kubectl describe pod <pod> | grep "Exit Code"
```

| Exit Code | Meaning |
|-----------|---------|
| `0` | Clean exit (check why pod isn't staying alive) |
| `1` | Application error |
| `2` | Misuse of shell command |
| `126` | Permission denied |
| `127` | Command not found |
| `137` | OOM killed (SIGKILL) |
| `143` | Graceful termination (SIGTERM) |

### Debugging Commands

```bash
# Get all pod events
kubectl describe pod <pod> -n <ns>

# Logs (current)
kubectl logs <pod> -n <ns>

# Logs (previous crashed container)
kubectl logs <pod> -n <ns> --previous

# Logs (specific container in multi-container pod)
kubectl logs <pod> -n <ns> -c <container-name>

# Shell into running pod
kubectl exec -it <pod> -n <ns> -- /bin/sh
kubectl exec -it <pod> -n <ns> -- /bin/bash

# Shell into specific container
kubectl exec -it <pod> -n <ns> -c <container> -- /bin/sh

# Debug without modifying original pod
kubectl debug -it <pod> --image=busybox --copy-to=debug-pod
kubectl debug node/<node> -it --image=ubuntu
```

### Fix Stuck Terminating Pod

```bash
# Force delete
kubectl delete pod <pod> -n <ns> --force --grace-period=0

# If still stuck, remove finalizers
kubectl patch pod <pod> -n <ns> \
  -p '{"metadata":{"finalizers":[]}}' \
  --type=merge
```

### ImagePullBackOff Fixes

```bash
# Verify image name
kubectl describe pod <pod> | grep Image:
docker pull <image>   # test manually if possible

# Check for registry secret
kubectl get secrets -n <ns> | grep docker

# Add registry secret to pod
kubectl create secret docker-registry regcred \
  --docker-server=<server> \
  --docker-username=<user> \
  --docker-password=<pass> \
  -n <ns>

# Reference in pod spec:
# spec:
#   imagePullSecrets:
#   - name: regcred
```

---

## 3. Control Plane Troubleshooting

### Check All Control Plane Components

```bash
# All kube-system pods
kubectl get pods -n kube-system -o wide

# Check component health (older API, may be deprecated)
kubectl get componentstatuses

# API server health
curl -k https://localhost:6443/healthz
curl -k https://localhost:6443/readyz
```

### kube-apiserver Issues

```bash
# Static pod manifest
cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Logs (if pod is running)
kubectl logs -n kube-system kube-apiserver-<node>

# If pod won't start, check the manifest for:
# - Wrong cert path
# - Invalid flags
# - Typos in etcd endpoint

# API server logs via docker/containerd (if pod is down)
crictl ps | grep apiserver
crictl logs <container-id>
```

### kube-scheduler Issues

```bash
# Check scheduler pod
kubectl get pods -n kube-system | grep scheduler
kubectl logs -n kube-system kube-scheduler-<node>

# Check manifest
cat /etc/kubernetes/manifests/kube-scheduler.yaml

# Verify scheduler is processing pods
kubectl get pods -A | grep Pending
kubectl describe pod <pending-pod> | grep "No scheduler"
```

### kube-controller-manager Issues

```bash
kubectl logs -n kube-system kube-controller-manager-<node>
cat /etc/kubernetes/manifests/kube-controller-manager.yaml

# Symptom: Deployments not scaling, pods not created from ReplicaSets
```

### ETCD Issues

```bash
# Check ETCD pod
kubectl get pods -n kube-system | grep etcd
kubectl logs -n kube-system etcd-<node>

# Verify ETCD health
ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# List ETCD members
ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

---

## 4. Networking Troubleshooting

### Service Has No Endpoints

**Most common networking issue in the CKA exam.**

```bash
# Check endpoints
kubectl get endpoints <svc> -n <ns>

# If empty → labels don't match
kubectl describe svc <svc> -n <ns>   # check "Selector:"
kubectl get pods -n <ns> --show-labels   # compare labels

# Fix: update service selector to match pod labels
kubectl edit svc <svc> -n <ns>
# OR fix pod labels
kubectl label pod <pod> -n <ns> <key>=<value>
```

### Pod-to-Pod Connectivity

```bash
# Test from inside a pod
kubectl exec -it <pod> -n <ns> -- curl http://<target-pod-ip>:<port>
kubectl exec -it <pod> -n <ns> -- wget -qO- http://<target-pod-ip>:<port>

# Test DNS resolution
kubectl run dns-test --image=busybox --rm -it -- nslookup <svc>.<ns>.svc.cluster.local
kubectl run dns-test --image=busybox --rm -it -- wget -qO- http://<svc>.<ns>.svc.cluster.local

# Check CNI plugin is running
kubectl get pods -n kube-system | grep -E "calico|weave|flannel|cilium"
```

### CoreDNS Issues

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Check CoreDNS config
kubectl get configmap coredns -n kube-system -o yaml

# Restart CoreDNS
kubectl rollout restart deployment coredns -n kube-system

# Check the kube-dns service
kubectl get svc kube-dns -n kube-system
```

### Network Policy Blocking Traffic

```bash
# List all network policies in namespace
kubectl get networkpolicy -n <ns>
kubectl describe networkpolicy <name> -n <ns>

# Test without network policy (if you suspect a policy is blocking)
# Temporarily delete the blocking policy to confirm
kubectl delete networkpolicy <name> -n <ns>  # only for testing
```

### kube-proxy Issues

```bash
# Check kube-proxy is running
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# Check kube-proxy logs
kubectl logs -n kube-system <kube-proxy-pod>

# Check iptables rules (on node)
iptables -t nat -L | grep <service-ip>
```

---

## 5. Storage Troubleshooting

### PVC Stuck in `Pending`

```bash
# Check PVC
kubectl describe pvc <pvc-name> -n <ns>

# Common reasons:
# 1. No matching PV (check capacity, accessMode, storageClass)
kubectl get pv
kubectl describe pvc <name> | grep -E "StorageClass|AccessModes|Capacity"

# 2. StorageClass doesn't exist
kubectl get storageclass

# 3. Dynamic provisioner not running
kubectl get pods -n kube-system | grep provisioner
```

### Pod Can't Mount Volume

```bash
kubectl describe pod <pod> -n <ns>
# Look for: "Unable to attach or mount volumes"
# Look for: "FailedMount" in events

# Check PVC is bound
kubectl get pvc -n <ns>

# Check PV reclaim policy
kubectl describe pv <pv-name>
```

### PV/PVC Binding Issues

```bash
# Check PV status
kubectl get pv
# STATUS column: Available, Bound, Released, Failed

# If PV is Released (previously bound to a deleted PVC)
# You may need to remove claimRef to make it bindable again
kubectl edit pv <pv-name>
# Remove spec.claimRef section
```

---

## 6. Application-Level Troubleshooting

### Liveness/Readiness Probe Failures

```bash
# Check probe configuration
kubectl describe pod <pod> | grep -A10 "Liveness:"
kubectl describe pod <pod> | grep -A10 "Readiness:"

# Check events for probe failures
kubectl describe pod <pod> | grep "Liveness probe failed"

# Test probe manually
kubectl exec <pod> -- curl -f http://localhost:<port>/health

# Common fixes:
# - Increase initialDelaySeconds
# - Fix the health endpoint path
# - Correct the port number
```

### ConfigMap/Secret Not Mounted

```bash
# Check if CM/Secret exists
kubectl get configmap <name> -n <ns>
kubectl get secret <name> -n <ns>

# Check pod volume mounts
kubectl describe pod <pod> | grep -A10 Volumes
kubectl describe pod <pod> | grep -A10 "Mounts:"

# Verify values inside pod
kubectl exec <pod> -- env | grep <KEY>
kubectl exec <pod> -- cat /path/to/mounted/file
```

---

## 7. Cluster-Wide Diagnostics

### Full Cluster Health Check

```bash
# Nodes
kubectl get nodes -o wide

# All pods (look for non-Running)
kubectl get pods -A | grep -v "Running\|Completed"

# All events (recent)
kubectl get events -A --sort-by='.lastTimestamp' | tail -30

# Resource usage
kubectl top nodes
kubectl top pods -A --sort-by=cpu | head -10

# Control plane health
kubectl get pods -n kube-system

# Check for failed deployments
kubectl get deployments -A | grep -v "READY"
```

### Certificate Expiration Check

```bash
# Check control plane certificate expiry
kubeadm certs check-expiration

# Renew all certs (if expiring)
kubeadm certs renew all
systemctl restart kubelet
```

---

## 8. Quick-Reference Diagnostic Commands

```bash
# Pod resource usage
kubectl top pods -n <ns> --containers

# Wide output (shows node assignment)
kubectl get pods -n <ns> -o wide

# Watch pod status in real time
kubectl get pods -n <ns> -w

# Get raw YAML of any resource
kubectl get <resource> <name> -n <ns> -o yaml

# Filter events by reason
kubectl get events -n <ns> --field-selector reason=OOMKilling
kubectl get events -n <ns> --field-selector reason=BackOff

# Get all objects in namespace
kubectl get all -n <ns>

# Check API server audit logs (if enabled)
tail -f /var/log/kubernetes/audit.log
```

---

*Part of the [CKA Certification Guide](./README.md)*
