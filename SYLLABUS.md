# CKA v1.35 Official Syllabus

> **Source:** [CNCF CKA Curriculum v1.35](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.35.pdf) | **Kubernetes version in exam:** v1.35 | **Updated:** 2026

---

## 📊 Domain Weights at a Glance

| # | Domain | Exam Weight |
|---|--------|:-----------:|
| 1 | [Cluster Architecture, Installation & Configuration](#1-cluster-architecture-installation--configuration-25) | **25%** |
| 2 | [Workloads & Scheduling](#2-workloads--scheduling-15) | **15%** |
| 3 | [Storage](#3-storage-10) | **10%** |
| 4 | [Services & Networking](#4-services--networking-20) | **20%** |
| 5 | [Troubleshooting](#5-troubleshooting-30) | **30%** |

> [!TIP]
> **Troubleshooting (30%)** is the highest-weighted domain. Invest at least 1/3 of your study time there.

---

## 1. Cluster Architecture, Installation & Configuration (25%)

> 📖 Study Notes: [01-cluster-architecture.md](./study-notes/01-cluster-architecture.md)

### 1.1 Manage role-based access control (RBAC)
- Roles vs ClusterRoles (namespace vs cluster scope)
- RoleBindings and ClusterRoleBindings
- `kubectl auth can-i` to verify permissions
- ServiceAccount token projection

```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods -n my-ns
kubectl create rolebinding read-pods --role=pod-reader --serviceaccount=my-ns:my-sa -n my-ns
kubectl auth can-i list pods --as=system:serviceaccount:my-ns:my-sa -n my-ns
```

### 1.2 Prepare underlying infrastructure for installing a Kubernetes cluster
- Disable swap, load kernel modules (`br_netfilter`, `overlay`)
- Enable sysctl: `net.ipv4.ip_forward=1`, `net.bridge.bridge-nf-call-iptables=1`
- Install and configure containerd as the container runtime
- Required ports: 6443, 2379-2380, 10250, 10257, 10259

```bash
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
modprobe overlay && modprobe br_netfilter
sysctl --system
```

### 1.3 Create and manage Kubernetes clusters using kubeadm
- `kubeadm init` with multi-part config (InitConfiguration, ClusterConfiguration, KubeletConfiguration, KubeProxyConfiguration)
- Install CNI plugin post-init
- `kubeadm join` for worker nodes
- `kubeadm token create --print-join-command`

```bash
kubeadm init --config=kubeadm-config.yaml
mkdir -p $HOME/.kube && sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
kubeadm token create --print-join-command
```

### 1.4 Manage the lifecycle of Kubernetes clusters
- Upgrade control plane: `kubeadm upgrade apply vX.Y.Z`
- Upgrade worker nodes: drain → upgrade packages → uncordon
- Backup/restore etcd
- Certificate renewal: `kubeadm certs renew all`

```bash
kubeadm certs check-expiration
kubeadm upgrade apply v1.35.x
apt-get install -y kubelet=1.35.x-* kubectl=1.35.x-*
systemctl daemon-reload && systemctl restart kubelet

# etcd backup
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

### 1.5 Use Helm and Kustomize to install cluster components
**Helm:**
```bash
helm repo add stable https://charts.helm.sh/stable && helm repo update
helm install my-release stable/nginx-ingress --set controller.replicaCount=2
helm upgrade my-release stable/nginx-ingress -f custom-values.yaml
helm rollback my-release 1
helm uninstall my-release
```

**Kustomize:**
```bash
kubectl apply -k ./overlays/production/
kubectl kustomize ./overlays/production/   # preview without applying
```

### 1.6 Understand extension interfaces (CNI, CSI, CRI)
- **CRI** (Container Runtime Interface): containerd, CRI-O
- **CNI** (Container Network Interface): Calico, Flannel, Cilium
- **CSI** (Container Storage Interface): storage plugins

```bash
crictl ps && crictl images && crictl logs <container-id>
ls /etc/cni/net.d/ && ls /opt/cni/bin/
kubectl get csidrivers && kubectl get csinodes
```

### 1.7 Understand CRDs, install and configure operators
- CRDs extend the Kubernetes API with custom resource kinds
- Operator pattern: packages operational knowledge into a controller

```bash
kubectl get crd
kubectl describe crd <crd-name>
kubectl apply -f my-custom-resource.yaml
kubectl get <custom-resource-name>
```

---

## 2. Workloads & Scheduling (15%)

> 📖 Study Notes: [02-workloads-scheduling.md](./study-notes/02-workloads-scheduling.md)

### 2.1 Understand Deployments and how to perform rolling updates and rollbacks
```bash
kubectl set image deployment/nginx-app nginx=nginx:1.25
kubectl rollout status deployment/nginx-app
kubectl rollout history deployment/nginx-app
kubectl rollout undo deployment/nginx-app
kubectl rollout undo deployment/nginx-app --to-revision=2
kubectl rollout pause deployment/nginx-app
kubectl rollout resume deployment/nginx-app
```

### 2.2 Use ConfigMaps and Secrets to configure applications
```bash
# ConfigMaps
kubectl create configmap app-config --from-literal=APP_ENV=production
kubectl create configmap nginx-conf --from-file=nginx.conf

# Secrets
kubectl create secret generic db-creds --from-literal=username=admin --from-literal=password=s3cr3t
kubectl create secret tls my-tls --cert=tls.crt --key=tls.key
```

### 2.3 Configure workload autoscaling
- Horizontal Pod Autoscaler (HPA) — requires Metrics Server
- `minReplicas`, `maxReplicas`, `targetCPUUtilizationPercentage`

```bash
kubectl autoscale deployment nginx-app --min=2 --max=10 --cpu-percent=50
kubectl get hpa
kubectl describe hpa nginx-app
```

### 2.4 Understand the primitives used to create robust, self-healing application deployments
- Liveness, Readiness, Startup probes (httpGet, tcpSocket, exec)
- PodDisruptionBudgets (PDB): `minAvailable` or `maxUnavailable`
- PriorityClass and pod priority/preemption
- Init containers (run-to-completion before main container)
- RestartPolicy: `Always`, `OnFailure`, `Never`

```bash
kubectl create poddisruptionbudget my-pdb --selector=app=nginx --min-available=2
kubectl get pdb
```

### 2.5 Configure Pod admission and scheduling (limits, node affinity, etc.)
- Resource requests and limits (CPU, memory)
- LimitRange and ResourceQuota
- Node affinity: `requiredDuringScheduling...` vs `preferredDuringScheduling...`
- Taints and Tolerations, NodeSelector, NodeName
- Pod topology spread constraints

```bash
kubectl taint nodes node1 dedicated=gpu:NoSchedule
kubectl taint nodes node1 dedicated=gpu:NoSchedule-   # remove taint
kubectl label node node1 disktype=ssd
kubectl create quota my-quota --hard=pods=10,requests.cpu=4,limits.memory=8Gi -n my-ns
```

---

## 3. Storage (10%)

> 📖 Study Notes: [03-storage.md](./study-notes/03-storage.md)

### 3.1 Implement storage classes and dynamic volume provisioning
- `reclaimPolicy`: `Retain` or `Delete`
- `volumeBindingMode`: `Immediate` or `WaitForFirstConsumer`
- Default StorageClass annotation

```bash
kubectl get sc
kubectl patch storageclass local-storage \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### 3.2 Configure volume types, access modes and reclaim policies
| Access Mode | Abbreviation | Description |
|-------------|-------------|-------------|
| ReadWriteOnce | RWO | Single node read-write |
| ReadOnlyMany | ROX | Many nodes read-only |
| ReadWriteMany | RWX | Many nodes read-write |
| ReadWriteOncePod | RWOP | Single pod read-write (K8s 1.22+) |

**Volume types:** `hostPath`, `emptyDir`, `configMap`, `secret`, `persistentVolumeClaim`, `nfs`

### 3.3 Manage persistent volumes and persistent volume claims
- PV lifecycle: Available → Bound → Released → Reclaimed
- PVC binds by matching `accessMode` + `storageClassName` + `capacity`

```bash
kubectl get pv,pvc
kubectl describe pvc my-pvc
```

```yaml
# PVC example
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: local-storage
  resources:
    requests:
      storage: 5Gi
```

---

## 4. Services & Networking (20%)

> 📖 Study Notes: [04-services-networking.md](./study-notes/04-services-networking.md)

### 4.1 Understand connectivity between Pods
```bash
kubectl get pods -o wide                                    # Get pod IPs
kubectl exec my-pod -- curl <other-pod-ip>:<port>          # Test connectivity
kubectl exec my-pod -- nslookup <svc>.default.svc.cluster.local
```

### 4.2 Define and enforce Network Policies
- Default: all traffic allowed; NetworkPolicy restricts
- Requires CNI that supports NetworkPolicy (Calico, Cilium)

```yaml
# Default deny-all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes: [Ingress]
```

### 4.3 Use ClusterIP, NodePort, LoadBalancer service types and endpoints
| Type | Use Case | Access Pattern |
|------|----------|---------------|
| ClusterIP | Internal only | `<clusterIP>:<port>` |
| NodePort | External via node | `<NodeIP>:<NodePort>` |
| LoadBalancer | Cloud external LB | External IP |
| ExternalName | DNS alias | CNAME |

```bash
kubectl expose deployment nginx --port=80 --type=NodePort --name=nginx-np
kubectl get endpoints nginx-np
```

### 4.4 Use the Gateway API to manage Ingress traffic
- Resources: `GatewayClass`, `Gateway`, `HTTPRoute`, `TCPRoute`
- Supports TLS termination, header routing, traffic splitting

### 4.5 Know how to use Ingress controllers and Ingress resources
```bash
kubectl get ing -A
kubectl describe ing my-ingress -n my-namespace
```

### 4.6 Understand and use CoreDNS
- Service DNS: `<service>.<namespace>.svc.cluster.local`
- Configured via `coredns` ConfigMap in `kube-system`

```bash
kubectl get cm coredns -n kube-system -o yaml
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup kubernetes
```

---

## 5. Troubleshooting (30%)

> 📖 Study Notes: [05-troubleshooting.md](./study-notes/05-troubleshooting.md)

> [!IMPORTANT]
> This is the **highest weighted domain (30%)**. Master every sub-topic here.

### 5.1 Troubleshoot clusters and nodes
```bash
kubectl get nodes
kubectl describe node <node-name>              # Check conditions and events
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl cordon <node-name>
kubectl uncordon <node-name>
```
**Node NotReady causes:** kubelet down, CNI missing, disk/memory pressure, container runtime issues.

### 5.2 Troubleshoot cluster components
```bash
ls /etc/kubernetes/manifests/                  # Static pod manifests
kubectl logs kube-apiserver-<node> -n kube-system
systemctl status kubelet
journalctl -u kubelet --since "5 minutes ago"

# etcd health check
ETCDCTL_API=3 etcdctl endpoint health \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# etcd restore
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db --data-dir=/var/lib/etcd-restore
```

### 5.3 Monitor cluster and application resource usage
```bash
kubectl top nodes
kubectl top pods -A --sort-by=cpu
kubectl top pods -A --sort-by=memory
```

### 5.4 Manage and evaluate container output streams
```bash
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>   # Multi-container pod
kubectl logs <pod-name> -f                    # Follow live
kubectl logs <pod-name> --previous            # Previous crashed container
kubectl logs <pod-name> --tail=50
kubectl logs -l app=nginx --all-containers=true
```

### 5.5 Troubleshoot services and networking
```bash
# Check selector matches pod labels
kubectl get svc <svc-name> -o yaml | grep -A5 selector
kubectl get pods --show-labels

# Empty endpoints = selector mismatch
kubectl get endpoints <svc-name>

# Test from inside a pod
kubectl exec -it test-pod -- curl <svc-name>.<ns>.svc.cluster.local
kubectl exec -it test-pod -- nslookup <svc-name>
```

---

## 📚 Official References

| Resource | Link |
|----------|------|
| CNCF CKA Curriculum v1.35 | [GitHub PDF](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.35.pdf) |
| LF Important Instructions | [docs.linuxfoundation.org](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad) |
| LF Exam FAQ | [docs.linuxfoundation.org](https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks) |
| Kubernetes Docs (allowed in exam) | [kubernetes.io/docs](https://kubernetes.io/docs) |
| Killer.sh CKA Simulator | [killer.sh](https://killer.sh) |
| Allowed Resources | [LF Certification Resources](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed) |
