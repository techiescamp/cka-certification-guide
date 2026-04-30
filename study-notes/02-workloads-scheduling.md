# Domain 2: Workloads & Scheduling

> **Exam Weight: 15%** — Focus on Deployments, scheduling constraints, and resource management.

---

## Workload Types

| Kind | Use Case |
|------|----------|
| `Pod` | Smallest deployable unit — rarely created directly |
| `Deployment` | Stateless apps — manages ReplicaSets, supports rolling updates |
| `ReplicaSet` | Ensures N pod replicas — managed by Deployment |
| `StatefulSet` | Stateful apps — stable network identity, ordered pod management |
| `DaemonSet` | Runs one pod per node — log agents, monitoring |
| `Job` | Run-to-completion — batch processing |
| `CronJob` | Scheduled jobs |

---

## Deployments

### Deployment Strategy Types

**RollingUpdate (default):**
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # extra pods allowed during update
      maxUnavailable: 0    # min pods that must remain available
```

**Recreate:**
```yaml
spec:
  strategy:
    type: Recreate   # kills all pods, then creates new ones (downtime)
```

### Rollout Commands

```bash
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=<n>
kubectl rollout pause deployment/<name>
kubectl rollout resume deployment/<name>
```

### Update Image

```bash
kubectl set image deployment/<name> <container>=<new-image>
# Example:
kubectl set image deployment/webapp nginx=nginx:1.26
```

---

## Scheduling

### How the Scheduler Works

1. **Filtering:** Remove nodes that don't meet requirements (resources, taints, affinity)
2. **Scoring:** Rank remaining nodes (least utilized, image locality, etc.)
3. **Binding:** Assign pod to winning node

### Resource Requests vs Limits

| | Request | Limit |
|--|---------|-------|
| **Purpose** | What the pod *needs* (used for scheduling) | Maximum the pod *can use* |
| **Effect** | Scheduler reserves this capacity on a node | Exceeded CPU → throttled; exceeded memory → OOMKilled |

```yaml
resources:
  requests:
    cpu: "250m"      # 0.25 cores
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"
```

### Quality of Service (QoS) Classes

| Class | Condition |
|-------|-----------|
| `Guaranteed` | requests == limits for all containers |
| `Burstable` | At least one container has requests set |
| `BestEffort` | No requests or limits set (evicted first under pressure) |

---

## Scheduling Constraints

### NodeSelector (simple label matching)

```yaml
spec:
  nodeSelector:
    disktype: ssd
```

```bash
kubectl label node node01 disktype=ssd
```

### Node Affinity (advanced label matching)

```yaml
spec:
  affinity:
    nodeAffinity:
      # Hard requirement (pod stays pending if not met)
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: zone
            operator: In
            values: [us-east-1a, us-east-1b]
      # Soft preference (scheduler prefers but not required)
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values: [ssd]
```

### Pod Affinity & Anti-Affinity

```yaml
spec:
  affinity:
    podAffinity:
      # Co-locate with pods labeled app=cache
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: cache
        topologyKey: kubernetes.io/hostname
    podAntiAffinity:
      # Don't co-locate replicas on same node
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: web
          topologyKey: kubernetes.io/hostname
```

### Taints & Tolerations

**Taints** on nodes prevent pods from scheduling there (unless they tolerate).

```bash
# Effects:
# NoSchedule        → New pods without toleration won't schedule
# PreferNoSchedule  → Avoid scheduling but not required
# NoExecute         → Evict existing pods + prevent new ones
```

```yaml
# Toleration in pod spec:
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  # Tolerate any taint with effect NoSchedule:
  - operator: "Exists"
    effect: "NoSchedule"
```

---

## ConfigMaps & Secrets

### ConfigMap Usage Patterns

```yaml
# 1. As environment variables
envFrom:
- configMapRef:
    name: app-config

# 2. As specific env var
env:
- name: PORT
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: PORT

# 3. As mounted file
volumes:
- name: config-vol
  configMap:
    name: app-config
containers:
- volumeMounts:
  - name: config-vol
    mountPath: /etc/config
```

### Secret Types

| Type | Use |
|------|-----|
| `Opaque` | Generic key-value (default) |
| `kubernetes.io/tls` | TLS cert and key |
| `kubernetes.io/dockerconfigjson` | Registry auth |
| `kubernetes.io/service-account-token` | SA tokens |

**Note:** Secrets are base64-encoded, not encrypted by default. Use EncryptionConfiguration for encryption at rest.

---

## Health Probes

| Probe | Purpose | What Happens on Failure |
|-------|---------|------------------------|
| `livenessProbe` | Is the container alive? | Container is restarted |
| `readinessProbe` | Is the container ready for traffic? | Pod removed from Service endpoints |
| `startupProbe` | Has the app finished starting? | Liveness/readiness disabled until it passes |

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20
  failureThreshold: 3

readinessProbe:
  exec:
    command: ["cat", "/tmp/ready"]
  initialDelaySeconds: 5
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /started
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

---

## Init Containers

- Run to completion **before** main containers start
- Run sequentially (not in parallel)
- Use cases: wait for dependencies, pre-populate data, run setup scripts

```yaml
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nc -z db 5432; do sleep 2; done']
  containers:
  - name: app
    image: myapp
```

---

## Static Pods

- Managed directly by `kubelet` on a node (not by the API server)
- Manifests stored at `staticPodPath` in kubelet config (default: `/etc/kubernetes/manifests/`)
- Control plane components (apiserver, etcd, etc.) are static pods
- Changes take effect immediately when manifest is saved
- Shown in `kubectl get pods -n kube-system` as `<name>-<nodename>`

```bash
# Find staticPodPath
cat /var/lib/kubelet/config.yaml | grep staticPodPath
```

---

## Pod Priority & Preemption

```yaml
# 1. Create PriorityClass
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority workloads"

# 2. Reference in pod
spec:
  priorityClassName: high-priority
```

Higher priority pods can **preempt** (evict) lower priority pods when resources are tight.

---

## HorizontalPodAutoscaler (HPA)

```bash
kubectl autoscale deployment <name> \
  --cpu-percent=50 \
  --min=2 \
  --max=10
```

- Requires `metrics-server` to be installed
- Scales based on CPU/memory utilization or custom metrics
- Evaluation interval: 15 seconds (default)

---

## Admission Controllers

Intercept API requests before they're persisted to ETCD:

| Controller | Purpose |
|------------|---------|
| `NamespaceLifecycle` | Prevents operations on terminating namespaces |
| `LimitRanger` | Enforces resource limits in a namespace |
| `ResourceQuota` | Limits total resource usage per namespace |
| `PodSecurity` | Enforces pod security standards |
| `MutatingAdmissionWebhook` | Modifies objects (e.g., inject sidecar) |
| `ValidatingAdmissionWebhook` | Validates objects (custom rules) |

---

## Exam Focus Points for Domain 2

1. **Deployment updates & rollbacks** — Very commonly tested
2. **ConfigMaps and Secrets** — Know all 3 usage patterns
3. **Resource limits** — Know requests vs limits difference
4. **Taints & Tolerations** — Know all 3 effects
5. **Node Affinity** — Know required vs preferred syntax
6. **Static pods** — Know how to create/modify them

---

*Previous: [Domain 1 — Cluster Architecture](./01-cluster-architecture.md)*
*Next: [Domain 3 — Storage](./03-storage.md)*
