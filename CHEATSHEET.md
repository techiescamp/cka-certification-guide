# CKA Exam Cheatsheet ⚡

> Quick-reference command guide for the Certified Kubernetes Administrator exam.
> Organized by exam domain weight. Use `k` as alias for `kubectl`.

---

## Setup (Do This First in the Exam)

```bash
# Set kubectl alias
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"

# Enable autocompletion
source <(kubectl completion bash)
complete -F __start_kubectl k

# Check current context
k config get-contexts
k config use-context <context-name>

# Set default namespace
k config set-context --current --namespace=<namespace>
```

---

## Domain 1 — Cluster Architecture, Installation & Configuration (25%)

### RBAC

```bash
# Create Role
k create role pod-reader --verb=get,list,watch --resource=pods -n dev

# Create ClusterRole
k create clusterrole node-reader --verb=get,list,watch --resource=nodes

# Create RoleBinding
k create rolebinding dev-binding --role=pod-reader --user=jane -n dev

# Create ClusterRoleBinding
k create clusterrolebinding admin-binding --clusterrole=cluster-admin --user=jane

# Check permissions
k auth can-i get pods --as=jane -n dev
k auth can-i "*" "*"   # check all permissions for current user

# Describe bindings
k get rolebindings,clusterrolebindings -A | grep <user>
k describe rolebinding <name> -n <ns>
```

### ServiceAccounts

```bash
k create serviceaccount my-sa -n dev
k create rolebinding sa-binding --role=pod-reader --serviceaccount=dev:my-sa -n dev

# Use SA in a pod
# spec.serviceAccountName: my-sa
```

### kubeadm Cluster Init

```bash
# Initialize control plane
kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=1.35.0

# Join worker node (run on worker)
kubeadm token create --print-join-command

# Reset node
kubeadm reset -f
```

### Cluster Upgrade (kubeadm)

```bash
# On control plane — upgrade kubeadm FIRST to target version
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=1.35.x-*
apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.35.x
# Then upgrade kubelet + kubectl to same target version
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.35.x-* kubectl=1.35.x-*
apt-mark hold kubelet kubectl
systemctl daemon-reload && systemctl restart kubelet

# On worker nodes
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
apt-mark unhold kubeadm kubelet kubectl
apt-get install -y kubeadm=1.35.x-* kubelet=1.35.x-* kubectl=1.35.x-*
apt-mark hold kubeadm kubelet kubectl
kubeadm upgrade node
systemctl daemon-reload && systemctl restart kubelet
kubectl uncordon <node>
```

### Helm & Kustomize

```bash
# Helm
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install my-release stable/nginx --namespace dev
helm upgrade my-release stable/nginx --set replicaCount=3
helm rollback my-release 1
helm uninstall my-release

# Kustomize
kubectl apply -k ./overlays/production
kubectl kustomize ./base
```

---

## Domain 2 — Workloads & Scheduling (15%)

### Deployments

```bash
# Create
k create deployment nginx --image=nginx:1.25 --replicas=3

# Scale
k scale deployment nginx --replicas=5

# Update image (rolling update)
k set image deployment/nginx nginx=nginx:1.26

# Rollout management
k rollout status deployment/nginx
k rollout history deployment/nginx
k rollout undo deployment/nginx
k rollout undo deployment/nginx --to-revision=2
k rollout pause deployment/nginx
k rollout resume deployment/nginx

# Dry-run YAML
k create deployment nginx --image=nginx $do > deploy.yaml
```

### Pods

```bash
# Run pod
k run nginx --image=nginx --port=80
k run busybox --image=busybox --command -- sleep 3600

# Debug pod
k run debug --image=busybox -it --rm -- sh
k exec -it <pod> -- /bin/sh
k exec <pod> -c <container> -- <command>

# Copy files
k cp <pod>:/path/to/file ./local-file
k cp ./local-file <pod>:/path/to/file
```

### ConfigMaps & Secrets

```bash
# ConfigMap
k create configmap app-config --from-literal=ENV=prod --from-literal=PORT=8080
k create configmap app-config --from-file=config.properties

# Secret
k create secret generic db-secret --from-literal=password=mysecret
k create secret tls tls-secret --cert=tls.crt --key=tls.key
k create secret docker-registry reg-secret \
  --docker-server=registry.io \
  --docker-username=user \
  --docker-password=pass
```

### Resource Management

```yaml
# In pod spec:
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

### HPA (Horizontal Pod Autoscaler)

```bash
k autoscale deployment nginx --cpu-percent=50 --min=2 --max=10
k get hpa
```

### Taints & Tolerations

```bash
# Taint node
k taint nodes node1 key=value:NoSchedule
k taint nodes node1 key=value:NoExecute
k taint nodes node1 key=value:PreferNoSchedule

# Remove taint
k taint nodes node1 key=value:NoSchedule-

# Toleration in pod spec:
# tolerations:
# - key: "key"
#   operator: "Equal"
#   value: "value"
#   effect: "NoSchedule"
```

### Node Affinity & NodeSelector

```bash
# Label a node
k label node node1 disktype=ssd

# NodeSelector in pod spec:
# nodeSelector:
#   disktype: ssd

# Node Affinity (required):
# affinity:
#   nodeAffinity:
#     requiredDuringSchedulingIgnoredDuringExecution:
#       nodeSelectorTerms:
#       - matchExpressions:
#         - key: disktype
#           operator: In
#           values: [ssd]
```

### Static Pods

```bash
# Default static pod path
ls /etc/kubernetes/manifests/

# Find kubelet config for staticPodPath
cat /var/lib/kubelet/config.yaml | grep staticPodPath

# Edit a static pod manifest (kubelet auto-restarts pod on save)
vim /etc/kubernetes/manifests/kube-apiserver.yaml

# Watch for the pod to restart after editing
watch kubectl get pods -n kube-system

# If pod doesn't restart: check kubelet logs
journalctl -u kubelet -f
```

> Static pods are managed by kubelet directly, not the API server. Changes take effect within seconds of saving the manifest.

---

## Domain 3 — Storage (10%)

### PersistentVolume & PersistentVolumeClaim

```bash
k get pv,pvc -A
k describe pv <name>
k describe pvc <name> -n <ns>

# Check StorageClass
k get storageclass
k describe storageclass <name>
```

```yaml
# PV example
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-001
spec:
  capacity:
    storage: 1Gi
  accessModes: [ReadWriteOnce]
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data

---
# PVC example
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 500Mi
  storageClassName: standard
```

### Volume in Pod

```yaml
spec:
  volumes:
  - name: my-vol
    persistentVolumeClaim:
      claimName: my-pvc
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - mountPath: /data
      name: my-vol
```

---

## Domain 4 — Services & Networking (20%)

### Services

```bash
# Expose deployment
k expose deployment nginx --port=80 --type=ClusterIP
k expose deployment nginx --port=80 --type=NodePort
k expose deployment nginx --port=80 --type=LoadBalancer

# Create service (imperative)
k create service clusterip my-svc --tcp=80:8080
k create service nodeport my-svc --tcp=80:8080

# Get service details
k get svc -o wide
k describe svc <name>

# Test connectivity
k run test --image=busybox --rm -it -- wget -qO- http://<svc-name>.<ns>.svc.cluster.local
```

### DNS

```bash
# DNS format
<service>.<namespace>.svc.cluster.local
<pod-ip-dashes>.<namespace>.pod.cluster.local

# Test DNS
k run dns-test --image=busybox --rm -it -- nslookup kubernetes.default
k run dns-test --image=busybox --rm -it -- nslookup <svc>.<ns>.svc.cluster.local
```

### Network Policies

```yaml
# Default deny all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: dev
spec:
  podSelector: {}
  policyTypes: [Ingress]

---
# Allow specific ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: dev
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### Ingress

```bash
k get ingress -A
k describe ingress <name> -n <ns>

# Create basic ingress (imperative)
k create ingress my-ingress --rule="host.com/path=svc:80"
```

### CoreDNS

```bash
# Check CoreDNS pods
k get pods -n kube-system -l k8s-app=kube-dns

# View CoreDNS config
k get configmap coredns -n kube-system -o yaml
```

---

## Domain 5 — Troubleshooting (30%)

### Node Troubleshooting

```bash
k get nodes -o wide
k describe node <node-name>

# Check node conditions
k get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type

# SSH to node and check kubelet
systemctl status kubelet
journalctl -u kubelet -f
journalctl -u kubelet --since "10 minutes ago"

# Check kubelet config
cat /var/lib/kubelet/config.yaml

# Restart kubelet
systemctl restart kubelet
```

### Pod Troubleshooting

```bash
k get pods -A
k describe pod <pod> -n <ns>
k logs <pod> -n <ns>
k logs <pod> -n <ns> --previous          # crashed container logs
k logs <pod> -n <ns> -c <container>      # multi-container pod
k logs <pod> -n <ns> --tail=50 -f        # stream last 50 lines

# Events
k get events -n <ns> --sort-by='.lastTimestamp'
k get events -A --field-selector reason=Failed

# Debug with ephemeral container
k debug -it <pod> --image=busybox --target=<container>
```

### Common Pod States

| State | Likely Cause | Fix |
|-------|-------------|-----|
| `Pending` | No nodes match (resources/taints/affinity) | Check node resources, taints |
| `CrashLoopBackOff` | App error / bad config | Check logs with `--previous` |
| `ImagePullBackOff` | Wrong image name / no registry access | Check image name, secrets |
| `OOMKilled` | Memory limit exceeded | Increase memory limit |
| `Terminating` | Stuck finalizer | `k delete pod <pod> $now` |
| `ContainerCreating` | Volume not mounted / config missing | Check PVC, ConfigMap, Secret |

### Control Plane Troubleshooting

```bash
# Check static pod manifests
ls /etc/kubernetes/manifests/

# Check component pods
k get pods -n kube-system
k logs -n kube-system kube-apiserver-<node>
k logs -n kube-system etcd-<node>
k logs -n kube-system kube-controller-manager-<node>
k logs -n kube-system kube-scheduler-<node>

# Check API server directly
curl -k https://localhost:6443/healthz
```

### Service / Networking Troubleshooting

```bash
# Verify service endpoints
k get endpoints <svc-name> -n <ns>
k describe endpoints <svc-name> -n <ns>

# If endpoints are empty — labels may not match
k get pods -n <ns> --show-labels
k describe svc <svc-name> -n <ns>   # check selector

# Test service connectivity from a pod
k run curl-test --image=curlimages/curl --rm -it -- curl http://<svc>.<ns>:80

# Check kube-proxy
k get pods -n kube-system -l k8s-app=kube-proxy
k logs -n kube-system <kube-proxy-pod>
```

### Resource Usage

```bash
k top nodes
k top pods -A
k top pods -A --sort-by=memory
k top pods -n <ns> --containers
```

---

## General Productivity Tips

```bash
# Get all resources in a namespace
k get all -n <ns>

# Watch resources live
k get pods -n <ns> -w

# Force delete
k delete pod <pod> --force --grace-period=0

# Get YAML of existing resource
k get deployment nginx -o yaml

# Edit live resource
k edit deployment nginx

# Patch resource
k patch deployment nginx -p '{"spec":{"replicas":5}}'

# Label / annotate
k label pod <pod> env=prod
k annotate pod <pod> description="test pod"

# Port-forward for local testing
k port-forward svc/nginx 8080:80
k port-forward pod/nginx 8080:80

# Count resources
k get pods -A --no-headers | wc -l
```

---

## Common YAML Starters

```bash
# Generate YAML starters (dry-run)
k run nginx --image=nginx $do
k create deployment nginx --image=nginx $do
k create service clusterip svc --tcp=80:80 $do
k create configmap cm --from-literal=k=v $do
k create secret generic sec --from-literal=k=v $do
k create role r --verb=get --resource=pods $do
k create rolebinding rb --role=r --user=u $do
k create namespace ns $do
k create serviceaccount sa $do
```

---

*Part of the [CKA Certification Guide](./README.md)*
