# Domain 5: Troubleshooting

> **Exam Weight: 30%** — The highest-impact domain. Master the debug methodology.

---

## The Troubleshooting Mindset

1. **Don't panic** — Follow a systematic approach
2. **Describe first** — Events tell you 80% of the story
3. **Check logs** — Application and system logs for the rest
4. **Verify your fix** — Always confirm the resource is now healthy

---

## Troubleshooting Methodology

```
Problem Reported
      │
      ▼
kubectl get <resource>        ← What is the current state?
      │
      ▼
kubectl describe <resource>   ← Why is it in that state? (Events!)
      │
      ▼
kubectl logs <pod>            ← What did the application say?
      │
      ▼
systemctl / journalctl        ← What did the system/kubelet say?
      │
      ▼
Fix → Verify
```

---

## Node Troubleshooting

### Diagnosing a NotReady Node

```bash
# Step 1: Get node status
kubectl get nodes -o wide

# Step 2: Describe the node
kubectl describe node <node>
# Key sections:
# - Conditions: MemoryPressure, DiskPressure, PIDPressure, Ready
# - Events at the bottom

# Step 3: SSH to the node
ssh <node>

# Step 4: Check kubelet
systemctl status kubelet
journalctl -u kubelet -f
journalctl -u kubelet --since "30m ago"

# Step 5: Common fixes
systemctl start kubelet        # if stopped
systemctl enable kubelet       # if not enabled

# Step 6: Back on control plane
kubectl get nodes
```

### Node Conditions and Causes

| Condition | True Means | False Means |
|-----------|-----------|-------------|
| `Ready` | Node is healthy | Node is not ready |
| `MemoryPressure` | Low memory | Normal |
| `DiskPressure` | Low disk space | Normal |
| `PIDPressure` | Too many processes | Normal |
| `NetworkUnavailable` | Network not configured | Network OK |

### Disk Pressure

```bash
# On the node:
df -h
du -sh /var/lib/docker/*   # find large files
crictl images              # list container images
crictl rmi <image-id>      # remove unused images
```

---

## Pod Troubleshooting

### Step-by-Step Pod Debug Flow

```bash
# 1. Get overview
kubectl get pods -n <ns> -o wide

# 2. Describe for events
kubectl describe pod <pod> -n <ns>
# Always read the Events section at the bottom!

# 3. Check logs
kubectl logs <pod> -n <ns>

# 4. Previous container logs (after crash)
kubectl logs <pod> -n <ns> --previous

# 5. Specific container in multi-container pod
kubectl logs <pod> -n <ns> -c <container>

# 6. Shell into the pod
kubectl exec -it <pod> -n <ns> -- /bin/sh
```

### Pod State Decision Tree

```
Pod status?
├── Pending
│   ├── Events say "insufficient cpu/memory" → node resource issue
│   ├── Events say "0/N nodes are available" → check taints, affinity
│   ├── Events say "pod has unbound PVC" → check PVC status
│   └── Unschedulable → kubectl describe pod → check constraints
│
├── ContainerCreating
│   ├── Long time → check volume mounts, image pull
│   └── Events show "Unable to attach volume" → storage issue
│
├── CrashLoopBackOff
│   ├── Exit code 1 → app error, check logs
│   ├── Exit code 137 → OOMKilled, increase memory
│   ├── Exit code 126/127 → wrong command
│   └── kubectl logs --previous
│
├── ImagePullBackOff
│   ├── Wrong image name/tag
│   ├── Registry not accessible
│   └── Missing imagePullSecrets
│
├── Running (but misbehaving)
│   ├── Check logs
│   ├── Check env vars: kubectl exec -- env
│   └── Check liveness/readiness probe failures in describe
│
└── Terminating (stuck)
    ├── Has finalizers → patch to remove
    └── kubectl delete --force --grace-period=0
```

---

## Control Plane Troubleshooting

### Order of Investigation

1. Check static pod manifests
2. Check pod status in kube-system
3. Check logs of failing component
4. Check certificates

```bash
# All control plane pods
kubectl get pods -n kube-system

# Static pod manifests
ls /etc/kubernetes/manifests/
cat /etc/kubernetes/manifests/kube-apiserver.yaml
cat /etc/kubernetes/manifests/kube-scheduler.yaml
cat /etc/kubernetes/manifests/kube-controller-manager.yaml
cat /etc/kubernetes/manifests/etcd.yaml

# Component logs
kubectl logs -n kube-system kube-apiserver-<node>
kubectl logs -n kube-system kube-scheduler-<node>
kubectl logs -n kube-system kube-controller-manager-<node>
kubectl logs -n kube-system etcd-<node>
```

### When API Server is Down

You can't use `kubectl` — use `crictl` instead:

```bash
# On the control plane node
crictl ps | grep kube-apiserver
crictl logs <container-id>

# Also check /var/log/pods/
ls /var/log/pods/kube-system_kube-apiserver*/
cat /var/log/pods/kube-system_kube-apiserver*/kube-apiserver/0.log
```

### Common Static Pod Manifest Issues

```bash
# Symptom: Scheduler not running
# Check: /etc/kubernetes/manifests/kube-scheduler.yaml
# Common issues:
#   - Wrong --kubeconfig path (typo)
#   - Wrong image name/tag
#   - Invalid flag

# Fix: Edit the manifest file
# kubelet will automatically restart the pod

vim /etc/kubernetes/manifests/kube-scheduler.yaml
# Wait ~30 seconds
watch kubectl get pods -n kube-system | grep scheduler
```

---

## Networking Troubleshooting

### Service Not Reachable

```bash
# 1. Does the service exist?
kubectl get svc <svc> -n <ns>

# 2. Are there endpoints?
kubectl get endpoints <svc> -n <ns>
# If empty → selector doesn't match pod labels

# 3. Compare service selector vs pod labels
kubectl describe svc <svc> -n <ns>     # check Selector:
kubectl get pods -n <ns> --show-labels  # check Labels:

# 4. Fix selector or pod labels
kubectl edit svc <svc> -n <ns>         # fix selector
kubectl label pod <pod> -n <ns> <key>=<value>  # fix pod label

# 5. Test connectivity
kubectl run test --image=curlimages/curl --rm -it -- \
  curl http://<svc>.<ns>.svc.cluster.local
```

### DNS Not Working

```bash
# 1. Is CoreDNS running?
kubectl get pods -n kube-system -l k8s-app=kube-dns

# 2. Can pods resolve?
kubectl run dns-test --image=busybox --rm -it -- nslookup kubernetes.default

# 3. Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# 4. Check CoreDNS ConfigMap
kubectl get configmap coredns -n kube-system -o yaml
```

### CNI Plugin Not Working

```bash
# Pods stuck in ContainerCreating or network not working
kubectl get pods -n kube-system | grep -E "calico|weave|flannel|cilium"

# Check CNI plugin logs
kubectl logs -n kube-system <cni-pod>

# Check CNI config on node
ls /etc/cni/net.d/
cat /etc/cni/net.d/*.conf
```

---

## Application Troubleshooting

### Common Log Locations

```bash
# Pod logs
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous

# Node system logs
/var/log/syslog          # Ubuntu
/var/log/messages        # RHEL/CentOS

# Kubelet logs
journalctl -u kubelet

# Container logs on node (direct)
/var/log/pods/<namespace>_<pod>_<uid>/<container>/
```

### Finding the Root Cause

```bash
# Events sorted by time
kubectl get events -n <ns> --sort-by='.lastTimestamp'

# Filter events by type
kubectl get events -n <ns> --field-selector type=Warning

# Filter events by reason
kubectl get events -n <ns> --field-selector reason=OOMKilling
kubectl get events -n <ns> --field-selector reason=BackOff

# All events across all namespaces
kubectl get events -A --sort-by='.lastTimestamp' | tail -20
```

---

## Resource Monitoring

```bash
# Node resource usage
kubectl top nodes

# Pod resource usage (all namespaces)
kubectl top pods -A

# Sort by memory
kubectl top pods -A --sort-by=memory

# Sort by CPU
kubectl top pods -A --sort-by=cpu

# Per-container breakdown
kubectl top pods -n <ns> --containers

# Find top 3 CPU-consuming pods
kubectl top pods -A --sort-by=cpu --no-headers | head -3
```

---

## Maintenance Operations

### Drain a Node

```bash
# Safely evict all pods (except DaemonSets)
kubectl drain <node> \
  --ignore-daemonsets \
  --delete-emptydir-data

# For pods with local storage:
kubectl drain <node> \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force

# Bring node back
kubectl uncordon <node>
```

### Cordon vs Drain

| Command | What it Does |
|---------|-------------|
| `kubectl cordon <node>` | Marks node unschedulable (existing pods stay) |
| `kubectl drain <node>` | Marks unschedulable + evicts all eligible pods |
| `kubectl uncordon <node>` | Marks node schedulable again |

---

## Exam-Critical Troubleshooting Scenarios

### Scenario 1: Pod won't schedule
→ `kubectl describe pod` → Events → look for "no nodes available" → check taints, resources, affinity

### Scenario 2: Service has no traffic
→ `kubectl get endpoints` → if empty → labels don't match → fix selector

### Scenario 3: Node is NotReady
→ SSH → `systemctl status kubelet` → `systemctl start kubelet`

### Scenario 4: Pod crashes immediately
→ `kubectl logs --previous` → exit code 137 = OOM → increase memory limit

### Scenario 5: kube-scheduler not running
→ `cat /etc/kubernetes/manifests/kube-scheduler.yaml` → find the typo → fix it → wait for restart

### Scenario 6: Can't pull image
→ `kubectl describe pod` → "Failed to pull image" → check image name + pull secrets

---

## Exam Focus Points for Domain 5

1. **Node NotReady** — kubelet troubleshooting is almost always tested
2. **Service endpoints** — selector mismatch is the #1 networking issue
3. **Pod states** — know all states and their causes
4. **Log analysis** — `kubectl logs`, `--previous`, `journalctl -u kubelet`
5. **kubectl top** — know how to identify resource-hungry pods
6. **drain/uncordon** — maintenance workflow is commonly tested
7. **Control plane components** — know how to debug static pod manifests

---

*Previous: [Domain 4 — Services & Networking](./04-services-networking.md)*
*Back to [Main Guide](../README.md)*
