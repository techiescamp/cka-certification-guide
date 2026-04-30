# CKA Practice Questions 📝

> 34 exam-style scenario questions with full solutions.
> Cover all 5 CKA exam domains. Try each question before reading the solution.

---

## How to Use

1. Read the question carefully — note the **namespace** and **cluster context**
2. Attempt the solution yourself
3. Reveal the solution and compare
4. If wrong, understand *why* before moving on

---

## Domain 1 — Cluster Architecture, Installation & Configuration (25%)

---

### Q1 — RBAC: Create Role and Binding

**Task:** In namespace `rbac-test`, create a Role named `pod-manager` that allows `get`, `list`, `watch`, `create`, and `delete` on `pods`. Bind this role to user `alice`.

<details>
<summary>Solution</summary>

```bash
kubectl create namespace rbac-test

kubectl create role pod-manager \
  --verb=get,list,watch,create,delete \
  --resource=pods \
  -n rbac-test

kubectl create rolebinding pod-manager-binding \
  --role=pod-manager \
  --user=alice \
  -n rbac-test

# Verify
kubectl auth can-i get pods --as=alice -n rbac-test
kubectl auth can-i delete pods --as=alice -n rbac-test
kubectl auth can-i get secrets --as=alice -n rbac-test  # should be no
```
</details>

---

### Q2 — RBAC: ClusterRole for Node Read Access

**Task:** Create a ClusterRole named `node-viewer` that allows `get`, `list`, and `watch` on `nodes`. Create a ClusterRoleBinding named `node-viewer-binding` that binds it to ServiceAccount `monitor-sa` in namespace `monitoring`.

<details>
<summary>Solution</summary>

```bash
kubectl create namespace monitoring

kubectl create serviceaccount monitor-sa -n monitoring

kubectl create clusterrole node-viewer \
  --verb=get,list,watch \
  --resource=nodes

kubectl create clusterrolebinding node-viewer-binding \
  --clusterrole=node-viewer \
  --serviceaccount=monitoring:monitor-sa

# Verify
kubectl auth can-i list nodes --as=system:serviceaccount:monitoring:monitor-sa
```
</details>

---
---

### Q3 — Cluster Upgrade

**Task:** Upgrade the control plane node from Kubernetes v1.34.x to v1.35.0 using kubeadm. Ensure the kubelet and kubectl are also upgraded.

<details>
<summary>Solution</summary>

```bash
# Step 1: Update kubeadm
apt-get update
apt-mark unhold kubeadm
apt-get install -y kubeadm=1.34.0-*
apt-mark hold kubeadm

# Step 2: Plan and apply upgrade
kubeadm upgrade plan
kubeadm upgrade apply v1.35.0

# Step 3: Drain node
kubectl drain controlplane --ignore-daemonsets --delete-emptydir-data

# Step 4: Upgrade kubelet and kubectl
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.34.0-* kubectl=1.34.0-*
apt-mark hold kubelet kubectl
systemctl daemon-reload
systemctl restart kubelet

# Step 5: Uncordon
kubectl uncordon controlplane

# Verify
kubectl get nodes
```
</details>

---

### Q4 — ServiceAccount Token

**Task:** Create a ServiceAccount named `app-sa` in namespace `default`. Create a pod named `sa-pod` using image `nginx` that uses this service account. Verify the token is mounted.

<details>
<summary>Solution</summary>

```bash
kubectl create serviceaccount app-sa

kubectl run sa-pod --image=nginx \
  --dry-run=client -o yaml > sa-pod.yaml
```

Edit `sa-pod.yaml` to add:
```yaml
spec:
  serviceAccountName: app-sa
  containers:
  - name: sa-pod
    image: nginx
```

```bash
kubectl apply -f sa-pod.yaml

# Verify token is mounted
kubectl exec sa-pod -- ls /var/run/secrets/kubernetes.io/serviceaccount/
kubectl exec sa-pod -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
```
</details>

---

### Q5 — Kustomize

**Task:** There is a kustomization directory at `/opt/kustomize/base`. Apply the kustomization to create all resources defined within it.

<details>
<summary>Solution</summary>

```bash
kubectl apply -k /opt/kustomize/base

# Verify
kubectl kustomize /opt/kustomize/base   # preview without applying
kubectl get all -n <namespace>
```
</details>

---

## Domain 2 — Workloads & Scheduling (15%)

---

### Q6 — Deployment with Rolling Update

**Task:** Create a Deployment named `webapp` in namespace `web` with 3 replicas using image `nginx:1.24`. Then update the image to `nginx:1.25` and verify the rollout completes successfully.

<details>
<summary>Solution</summary>

```bash
kubectl create namespace web

kubectl create deployment webapp \
  --image=nginx:1.24 \
  --replicas=3 \
  -n web

kubectl set image deployment/webapp nginx=nginx:1.25 -n web

kubectl rollout status deployment/webapp -n web

# Verify
kubectl get pods -n web
kubectl describe deployment webapp -n web | grep Image
```
</details>

---

### Q7 — Rollback a Deployment

**Task:** The deployment `api-server` in namespace `production` was recently updated and is now failing. Roll it back to the previous version.

<details>
<summary>Solution</summary>

```bash
# Check rollout history
kubectl rollout history deployment/api-server -n production

# Roll back to previous version
kubectl rollout undo deployment/api-server -n production

# Or roll back to specific revision
kubectl rollout undo deployment/api-server -n production --to-revision=2

# Verify
kubectl rollout status deployment/api-server -n production
kubectl get pods -n production
```
</details>

---

### Q8 — ConfigMap & Secret in Pod

**Task:** Create a ConfigMap named `app-config` with key `APP_ENV=production` and `LOG_LEVEL=info`. Create a Secret named `db-secret` with key `DB_PASSWORD=supersecret`. Create a pod named `config-pod` using image `nginx` that exposes both as environment variables.

<details>
<summary>Solution</summary>

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=info

kubectl create secret generic db-secret \
  --from-literal=DB_PASSWORD=supersecret

kubectl run config-pod --image=nginx --dry-run=client -o yaml > config-pod.yaml
```

Edit `config-pod.yaml`:
```yaml
spec:
  containers:
  - name: config-pod
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASSWORD
```

```bash
kubectl apply -f config-pod.yaml

# Verify
kubectl exec config-pod -- env | grep -E "APP_ENV|LOG_LEVEL|DB_PASSWORD"
```
</details>

---

### Q9 — Pod with Resource Limits

**Task:** Create a pod named `limited-pod` in namespace `dev` using image `nginx`. Set CPU request to `100m`, CPU limit to `200m`, memory request to `64Mi`, and memory limit to `128Mi`.

<details>
<summary>Solution</summary>

```bash
kubectl run limited-pod --image=nginx -n dev \
  --requests='cpu=100m,memory=64Mi' \
  --limits='cpu=200m,memory=128Mi'

# Verify
kubectl describe pod limited-pod -n dev | grep -A6 "Limits:"
```
</details>

---

### Q10 — Node Affinity

**Task:** Label node `node01` with `tier=frontend`. Create a pod named `affinity-pod` using image `nginx` that is **required** to be scheduled on nodes with label `tier=frontend`.

<details>
<summary>Solution</summary>

```bash
kubectl label node node01 tier=frontend

kubectl run affinity-pod --image=nginx --dry-run=client -o yaml > affinity-pod.yaml
```

Edit `affinity-pod.yaml`:
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: tier
            operator: In
            values:
            - frontend
  containers:
  - name: affinity-pod
    image: nginx
```

```bash
kubectl apply -f affinity-pod.yaml

# Verify
kubectl get pod affinity-pod -o wide
```
</details>

---

### Q11 — Taint and Toleration

**Task:** Add a taint `env=production:NoSchedule` to node `node02`. Create a pod named `tolerate-pod` using image `busybox` that can be scheduled on this tainted node.

<details>
<summary>Solution</summary>

```bash
kubectl taint nodes node02 env=production:NoSchedule

kubectl run tolerate-pod --image=busybox --dry-run=client -o yaml \
  -- sleep 3600 > tolerate-pod.yaml
```

Edit `tolerate-pod.yaml`:
```yaml
spec:
  tolerations:
  - key: "env"
    operator: "Equal"
    value: "production"
    effect: "NoSchedule"
  containers:
  - name: tolerate-pod
    image: busybox
    command: ["sleep", "3600"]
```

```bash
kubectl apply -f tolerate-pod.yaml

# Verify it's on node02
kubectl get pod tolerate-pod -o wide
```
</details>

---

### Q12 — HorizontalPodAutoscaler

**Task:** Create an HPA for deployment `web-app` in namespace `production` that scales between 2 and 8 replicas, targeting 60% CPU utilization.

<details>
<summary>Solution</summary>

```bash
kubectl autoscale deployment web-app \
  --cpu-percent=60 \
  --min=2 \
  --max=8 \
  -n production

# Verify
kubectl get hpa -n production
kubectl describe hpa web-app -n production
```
</details>

---

### Q13 — Init Container

**Task:** Create a pod named `init-pod` in namespace `default` that has an init container using image `busybox` which runs `echo "Init complete" > /shared/init.txt`, and a main container using image `nginx` that mounts the same volume at `/usr/share/data`.

<details>
<summary>Solution</summary>

```yaml
# init-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: init-container
    image: busybox
    command: ['sh', '-c', 'echo "Init complete" > /shared/init.txt']
    volumeMounts:
    - name: shared-vol
      mountPath: /shared
  containers:
  - name: main-container
    image: nginx
    volumeMounts:
    - name: shared-vol
      mountPath: /usr/share/data
  volumes:
  - name: shared-vol
    emptyDir: {}
```

```bash
kubectl apply -f init-pod.yaml

# Verify init ran
kubectl exec init-pod -- cat /usr/share/data/init.txt
```
</details>

---

## Domain 3 — Storage (10%)

---

### Q14 — PersistentVolume

**Task:** Create a PersistentVolume named `pv-local` with `500Mi` capacity, `ReadWriteOnce` access mode, `Retain` reclaim policy, and a `hostPath` of `/mnt/pv-data`. Use `StorageClass: manual`.

<details>
<summary>Solution</summary>

```yaml
# pv-local.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-local
spec:
  capacity:
    storage: 500Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/pv-data
```

```bash
kubectl apply -f pv-local.yaml

# Verify
kubectl get pv pv-local
kubectl describe pv pv-local
```
</details>

---

### Q15 — PVC and Pod with Persistent Storage

**Task:** Create a PersistentVolumeClaim named `app-pvc` requesting `200Mi` with `ReadWriteOnce` and `storageClassName: manual`. Create a pod named `storage-pod` using image `nginx` that mounts this PVC at `/data`.

<details>
<summary>Solution</summary>

```yaml
# app-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 200Mi
---
# storage-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
spec:
  volumes:
  - name: storage-vol
    persistentVolumeClaim:
      claimName: app-pvc
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: storage-vol
      mountPath: /data
```

```bash
kubectl apply -f app-pvc.yaml
kubectl apply -f storage-pod.yaml

# Verify
kubectl get pvc app-pvc
kubectl describe pod storage-pod | grep -A5 Volumes
kubectl exec storage-pod -- ls /data
```
</details>

---

### Q16 — StorageClass

**Task:** List all StorageClasses in the cluster and identify which one is the default. Then create a PVC named `dynamic-pvc` that uses the default StorageClass and requests `1Gi` with `ReadWriteOnce`.

<details>
<summary>Solution</summary>

```bash
# Find default StorageClass
kubectl get storageclass
# Look for (default) annotation

# Create PVC (omit storageClassName to use default)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Verify
kubectl get pvc dynamic-pvc
```
</details>

---

## Domain 4 — Services & Networking (20%)

---

### Q17 — Create a Service

**Task:** Expose deployment `frontend` in namespace `web` on port `80` (target port `8080`) as a `ClusterIP` service named `frontend-svc`.

<details>
<summary>Solution</summary>

```bash
kubectl expose deployment frontend \
  --name=frontend-svc \
  --port=80 \
  --target-port=8080 \
  --type=ClusterIP \
  -n web

# Verify
kubectl get svc frontend-svc -n web
kubectl describe svc frontend-svc -n web
kubectl get endpoints frontend-svc -n web
```
</details>

---

### Q18 — NodePort Service

**Task:** Create a NodePort service named `api-nodeport` in namespace `backend` that exposes port `8080` of deployment `api` on node port `30080`.

<details>
<summary>Solution</summary>

```bash
kubectl expose deployment api \
  --name=api-nodeport \
  --port=8080 \
  --type=NodePort \
  -n backend \
  --dry-run=client -o yaml > nodeport.yaml
```

Edit `nodeport.yaml` to add `nodePort: 30080`:
```yaml
spec:
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
```

```bash
kubectl apply -f nodeport.yaml

# Verify
kubectl get svc api-nodeport -n backend
```
</details>

---

### Q19 — Network Policy: Default Deny

**Task:** Create a NetworkPolicy named `deny-all` in namespace `secure` that denies all ingress and egress traffic to all pods in that namespace.

<details>
<summary>Solution</summary>

```yaml
# deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: secure
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

```bash
kubectl apply -f deny-all.yaml

# Verify
kubectl get networkpolicy -n secure
kubectl describe networkpolicy deny-all -n secure
```
</details>

---

### Q20 — Network Policy: Allow Specific Traffic

**Task:** In namespace `app`, create a NetworkPolicy named `allow-frontend` that allows ingress traffic to pods with label `role=backend` only from pods with label `role=frontend` on port `3000`.

<details>
<summary>Solution</summary>

```yaml
# allow-frontend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: app
spec:
  podSelector:
    matchLabels:
      role: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 3000
```

```bash
kubectl apply -f allow-frontend.yaml
kubectl describe networkpolicy allow-frontend -n app
```
</details>

---

### Q21 — Ingress Resource

**Task:** Create an Ingress named `app-ingress` in namespace `web` that routes traffic from `app.example.com/api` to service `api-svc` on port `80` and from `app.example.com/` to service `frontend-svc` on port `80`.

<details>
<summary>Solution</summary>

```yaml
# app-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: web
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

```bash
kubectl apply -f app-ingress.yaml
kubectl get ingress -n web
kubectl describe ingress app-ingress -n web
```
</details>

---

### Q22 — DNS Troubleshooting

**Task:** Pod `debug-pod` in namespace `default` cannot resolve the service `my-service.production.svc.cluster.local`. Diagnose the issue.

<details>
<summary>Solution</summary>

```bash
# 1. Check if CoreDNS is running
kubectl get pods -n kube-system -l k8s-app=kube-dns

# 2. Test DNS from within a pod
kubectl run dns-debug --image=busybox --rm -it -- \
  nslookup my-service.production.svc.cluster.local

# 3. Check CoreDNS config
kubectl get configmap coredns -n kube-system -o yaml

# 4. Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# 5. Check service exists
kubectl get svc my-service -n production

# 6. Check pod's DNS policy
kubectl describe pod debug-pod | grep DNS
```
</details>

---

## Domain 5 — Troubleshooting (30%)

---

### Q23 — Fix NotReady Node

**Task:** Node `worker01` is in `NotReady` state. Investigate and fix the issue.

<details>
<summary>Solution</summary>

```bash
# 1. Check node status
kubectl describe node worker01

# 2. SSH to the node
ssh worker01

# 3. Check kubelet status
systemctl status kubelet

# 4. If kubelet is stopped, start it
systemctl start kubelet
systemctl enable kubelet

# 5. Check kubelet logs
journalctl -u kubelet -f
journalctl -u kubelet --since "30 minutes ago" | tail -50

# 6. Check kubelet config
cat /var/lib/kubelet/config.yaml

# 7. Common fixes:
# - Wrong cluster DNS
# - Certificate issues
# - Disk pressure (df -h)
# - Memory pressure (free -m)

# 8. Back on control plane, verify
kubectl get nodes
```
</details>

---

### Q24 — Fix CrashLoopBackOff Pod

**Task:** Pod `crasher` in namespace `debug` is in `CrashLoopBackOff`. Identify and resolve the issue.

<details>
<summary>Solution</summary>

```bash
# 1. Check pod status
kubectl describe pod crasher -n debug
# Look at: Events, Last State, Exit Code

# 2. Check current logs
kubectl logs crasher -n debug

# 3. Check previous container logs (before crash)
kubectl logs crasher -n debug --previous

# 4. Common causes & fixes:
# Exit code 1 → Application error, check app config/env
# Exit code 137 → OOM killed, increase memory limit
# Exit code 126/127 → Wrong command/entrypoint

# 5. If it's a config issue, edit the pod
kubectl get pod crasher -n debug -o yaml > crasher.yaml
# Fix the issue (bad env var, wrong command, etc.)
kubectl delete pod crasher -n debug
kubectl apply -f crasher.yaml

# 6. Verify
kubectl get pod crasher -n debug
```
</details>

---

### Q25 — Fix ImagePullBackOff

**Task:** Pod `bad-image` in namespace `default` is in `ImagePullBackOff`. Fix the image reference so the pod runs successfully.

<details>
<summary>Solution</summary>

```bash
# 1. Describe the pod to see the error
kubectl describe pod bad-image
# Look for "Failed to pull image" in events

# 2. Check the image name
kubectl get pod bad-image -o jsonpath='{.spec.containers[0].image}'

# 3. Fix by editing
kubectl edit pod bad-image
# Correct the image name/tag

# OR delete and recreate with correct image
kubectl delete pod bad-image
kubectl run bad-image --image=nginx:1.25   # use correct image

# 4. Verify
kubectl get pod bad-image
```
</details>

---

### Q26 — Service Not Routing Traffic

**Task:** Service `backend-svc` in namespace `production` has no endpoints. Pods are running but traffic is not reaching them. Fix the issue.

<details>
<summary>Solution</summary>

```bash
# 1. Check service and endpoints
kubectl get svc backend-svc -n production
kubectl get endpoints backend-svc -n production
# If endpoints are empty, selector doesn't match pods

# 2. Check service selector
kubectl describe svc backend-svc -n production
# Note the selector labels

# 3. Check pod labels
kubectl get pods -n production --show-labels

# 4. If labels don't match, fix the service selector
kubectl edit svc backend-svc -n production
# Update spec.selector to match pod labels

# OR fix the pod labels
kubectl label pod <pod-name> -n production app=backend  # add missing label

# 5. Verify endpoints are populated
kubectl get endpoints backend-svc -n production

# 6. Test connectivity
kubectl run test --image=busybox --rm -it -- \
  wget -qO- http://backend-svc.production.svc.cluster.local
```
</details>

---

### Q27 — Pod Stuck in Pending

**Task:** Pod `pending-pod` in namespace `default` is stuck in `Pending`. Investigate and fix.

<details>
<summary>Solution</summary>

```bash
# 1. Describe the pod
kubectl describe pod pending-pod
# Look at Events section

# 2. Common causes:
# a) Insufficient resources
kubectl describe nodes | grep -A5 "Allocated resources"

# b) Taint preventing scheduling
kubectl describe nodes | grep Taints

# c) NodeSelector/Affinity not matching
kubectl get pod pending-pod -o yaml | grep -A10 affinity
kubectl get pod pending-pod -o yaml | grep -A5 nodeSelector

# d) PVC not bound
kubectl get pvc -n default

# 3. Fixes:
# For taint issue: Add toleration to pod or remove taint
kubectl taint nodes node01 <key>-   # remove taint

# For resource issue: Delete other pods or add nodes
# For nodeSelector issue: Fix label or remove selector
kubectl edit pod pending-pod   # fix selector

# 4. Verify
kubectl get pod pending-pod
```
</details>

---

### Q28 — Identify High Resource Consuming Pod

**Task:** Find the pod consuming the most memory across all namespaces and write its name to `/opt/high-mem-pod.txt`.

<details>
<summary>Solution</summary>

```bash
# Install metrics-server if not present
kubectl top pods -A --sort-by=memory

# Get the top pod name
kubectl top pods -A --sort-by=memory --no-headers | head -1

# Write to file
kubectl top pods -A --sort-by=memory --no-headers | head -1 | awk '{print $2}' \
  > /opt/high-mem-pod.txt

cat /opt/high-mem-pod.txt
```
</details>

---

### Q29 — Fix Control Plane Component

**Task:** The kube-scheduler is not running. Identify the issue and fix it so pods get scheduled.

<details>
<summary>Solution</summary>

```bash
# 1. Check scheduler pod status
kubectl get pods -n kube-system | grep scheduler

# 2. Check logs if pod exists but is failing
kubectl logs -n kube-system kube-scheduler-<node>

# 3. Check static pod manifest
cat /etc/kubernetes/manifests/kube-scheduler.yaml
# Look for: wrong image, wrong flags, missing certs

# 4. Common issues:
# - Typo in --kubeconfig path
# - Wrong image name
# - Invalid flag

# 5. Fix the manifest (kubelet will restart the pod automatically)
vim /etc/kubernetes/manifests/kube-scheduler.yaml

# 6. Verify scheduler restarts
watch kubectl get pods -n kube-system | grep scheduler

# 7. Verify pods are now being scheduled
kubectl get pods -A | grep Pending
```
</details>

---

### Q30 — Drain and Cordon a Node

**Task:** Node `worker02` needs maintenance. Drain all workloads from it (ignoring DaemonSets) and then mark it as unschedulable. After "maintenance", bring it back online.

<details>
<summary>Solution</summary>

```bash
# Drain the node
kubectl drain worker02 \
  --ignore-daemonsets \
  --delete-emptydir-data

# Verify no pods (except daemonsets) are on worker02
kubectl get pods -A -o wide | grep worker02

# The node is now cordoned (unschedulable)
kubectl get nodes | grep worker02

# After maintenance, uncordon
kubectl uncordon worker02

# Verify node is schedulable
kubectl get nodes | grep worker02
```
</details>

---

### Q31 — Debug with Ephemeral Container

**Task:** Pod `minimal-pod` (using a distroless image) is misbehaving. Attach a debug container to investigate.

<details>
<summary>Solution</summary>

```bash
# Add an ephemeral debug container
kubectl debug -it minimal-pod \
  --image=busybox \
  --target=<container-name>

# Inside the debug container:
ls /proc/1/root   # view main container filesystem
cat /proc/1/cmdline   # view main process command
```
</details>

---

### Q32 — Multi-Container Pod Log Analysis

**Task:** Pod `multi-app` in namespace `logs` has containers named `app` and `sidecar`. The `app` container is failing. Get the last 100 lines of logs from the `app` container only, including logs from before the last restart.

<details>
<summary>Solution</summary>

```bash
# Current logs from app container
kubectl logs multi-app -c app -n logs --tail=100

# Previous (pre-crash) logs
kubectl logs multi-app -c app -n logs --previous --tail=100

# Stream logs
kubectl logs multi-app -c app -n logs -f

# Save to file
kubectl logs multi-app -c app -n logs --previous > /opt/app-logs.txt
```
</details>

---

### Q33 — Fix a Broken Deployment

**Task:** Deployment `broken-app` in namespace `production` was updated and is now failing with all pods in `Error` state. Identify the issue and roll back.

<details>
<summary>Solution</summary>

```bash
# 1. Check deployment and pods
kubectl get deployment broken-app -n production
kubectl get pods -n production -l app=broken-app

# 2. Check pod logs
kubectl logs -n production <pod-name>

# 3. Check rollout history
kubectl rollout history deployment/broken-app -n production

# 4. Describe a failing pod
kubectl describe pod <pod-name> -n production

# 5. Roll back
kubectl rollout undo deployment/broken-app -n production

# 6. Verify
kubectl rollout status deployment/broken-app -n production
kubectl get pods -n production
```
</details>

---

### Q34 — Full Scenario: Deploy and Expose a Stateful App

**Task:** Deploy a MySQL database:
- Deployment name: `mysql`, namespace: `database`, image: `mysql:8.0`, 1 replica
- Secret: `mysql-secret` with `MYSQL_ROOT_PASSWORD=rootpass`
- PVC: `mysql-pvc`, 1Gi, ReadWriteOnce, default StorageClass
- Mount PVC at `/var/lib/mysql`
- Expose as ClusterIP service `mysql-svc` on port 3306

<details>
<summary>Solution</summary>

```bash
kubectl create namespace database

kubectl create secret generic mysql-secret \
  --from-literal=MYSQL_ROOT_PASSWORD=rootpass \
  -n database
```

```yaml
# mysql-full.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: database
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_ROOT_PASSWORD
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: mysql-svc
  namespace: database
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
```

```bash
kubectl apply -f mysql-full.yaml

# Verify
kubectl get all -n database
kubectl get pvc -n database
```
</details>

---

## Score Yourself

| Questions Solved | Result |
|-----------------|--------|
| 28–34 | Exam-ready 🟢 |
| 21–27 | Almost there 🟡 |
| 14–20 | More practice needed 🟠 |
| < 15  | Focus on fundamentals 🔴 |

---

*Part of the [CKA Certification Guide](./README.md)*
