# Certified Kubernetes Administrator (CKA) Exam Preparation Guide V1.35 (2026)

![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35-326CE5?logo=kubernetes&logoColor=white)
![Exam](https://img.shields.io/badge/CKA-Exam%20Prep-green)
![Passing Score](https://img.shields.io/badge/Passing%20Score-66%25-blue)
![Duration](https://img.shields.io/badge/Duration-2%20Hours-orange)
![License](https://img.shields.io/badge/License-All%20Rights%20Reserved-red)

This is a detailed study guide with tips and practical examples to ace the Certified Kubernetes Administrator exam.

---
## Hit the Star! :star:
If you are planning to use this repo for reference, please hit the star. Thanks!

## CKA Exam Coupon (Exclusive Discount)

To save on CKA exam registration, use the following coupon code.
> [!IMPORTANT]
> **Coupon:** Use code **35KUBECT** at [kube.promo/cka](https://kube.promo/cka)

Use code **35KUBECT** to save on following bundles:

- CKA + CKAD ($370+ Savings): [kube.promo/cka-ckad](https://kube.promo/cka-ckad)
- CKA + CKS Bundle ($370+ Savings): [kube.promo/bundle](https://kube.promo/bundle)
- CKA + CKAD + CKS Exam bundle (35% Discount): [kube.promo/k8s-bundle](https://kube.promo/k8s-bundle)
- KCNA + KCSA + CKA + CKAD + CKS: [kube.promo/kubestronaut](https://kube.promo/kubestronaut)


---

## 📚 CKA Exam Detailed Study Guide

<details>
<summary><strong>Syllabus and Study Notes</strong></summary>

<br>

> **Source:** [CNCF CKA Curriculum v1.35](https://github.com/cncf/curriculum/blob/master/CKA_Curriculum_v1.35.pdf) | **Kubernetes version:** v1.35 | **Updated:** 2026

| # | Domain | Weight | Study Notes | Key Topics |
|:-:|--------|:------:|:-----------:|------------|
| 1 | 🏗️ Cluster Architecture, Installation & Configuration | **25%** | [Notes](./study-notes/01-cluster-architecture.md) | RBAC, kubeadm, Helm, Kustomize, CRDs, Operators |
| 2 | 📦 Workloads & Scheduling | **15%** | [Notes](./study-notes/02-workloads-scheduling.md) | Deployments, ConfigMaps, Secrets, HPA, affinity |
| 3 | 💾 Storage | **10%** | [Notes](./study-notes/03-storage.md) | StorageClasses, PV, PVC, dynamic provisioning |
| 4 | 🌐 Services & Networking | **20%** | [Notes](./study-notes/04-services-networking.md) | NetworkPolicies, Gateway API, Ingress, CoreDNS |
| 5 | 🛠️ Troubleshooting | **30%**  | [Notes](./study-notes/05-troubleshooting.md) | Pod failures, node issues, control plane, networking |

> [!TIP]
> **Troubleshooting (30%)** is the highest-weighted domain. Invest at least 1/3 of your study time there.

</details>

---

### [Cluster Architecture, Installation & Configuration](#1-cluster-architecture-installation--configuration-25) `25%`

> ![weight](https://img.shields.io/badge/Exam%20Weight-25%25-4A90D9?style=flat-square) &nbsp; 📖 [Study Notes](./study-notes/01-cluster-architecture.md)

| # | Topic |
|---|-------|
| 1 | 🔐 [Manage role-based access control (RBAC)](#manage-role-based-access-control-rbac) |
| 2 | 🖥️ [Prepare underlying infrastructure for installing a Kubernetes cluster](#prepare-underlying-infrastructure-for-installing-a-kubernetes-cluster) |
| 3 | ⚙️ [Create and manage Kubernetes clusters using kubeadm](#create-and-manage-kubernetes-clusters-using-kubeadm) |
| 4 | 🔄 [Manage the lifecycle of Kubernetes clusters](#manage-the-lifecycle-of-kubernetes-clusters) |
| 5 | 📦 [Use Helm and Kustomize to install cluster components](#use-helm-and-kustomize-to-install-cluster-components) |
| 6 | 🔌 [Understand extension interfaces (CNI, CSI, CRI, etc.)](#understand-extension-interfaces-cni-csi-cri-etc) |
| 7 | 🧩 [Understand CRDs, install and configure operators](#understand-crds-install-and-configure-operators) |

---

### [Workloads & Scheduling](#2-workloads--scheduling-15) `15%`

> ![weight](https://img.shields.io/badge/Exam%20Weight-15%25-7B68EE?style=flat-square) &nbsp; 📖 [Study Notes](./study-notes/02-workloads-scheduling.md)

| # | Topic |
|---|-------|
| 1 | 🔁 [Understand deployments and how to perform rolling updates and rollbacks](#understand-deployments-and-how-to-perform-rolling-update-and-rollbacks) |
| 2 | 🗂️ [Use ConfigMaps and Secrets to configure applications](#use-configmaps-and-secrets-to-configure-applications) |
| 3 | 📈 [Configure workload autoscaling](#configure-workload-autoscaling) |
| 4 | 🛡️ [Understand the primitives used to create robust, self-healing application deployments](#understand-the-primitives-used-to-create-robust-self-healing-application-deployments) |
| 5 | 🎯 [Configure Pod admission and scheduling (limits, node affinity, etc.)](#configure-pod-admission-and-scheduling-limits-node-affinity-etc) |

---

### [Storage](#3-storage-10) `10%`

> ![weight](https://img.shields.io/badge/Exam%20Weight-10%25-E8A838?style=flat-square) &nbsp; 📖 [Study Notes](./study-notes/03-storage.md)

| # | Topic |
|---|-------|
| 1 | 🏷️ [Implement storage classes and dynamic volume provisioning](#implement-storage-classes-and-dynamic-volume-provisioning) |
| 2 | 🔧 [Configure volume types, access modes and reclaim policies](#configure-volume-types-access-modes-and-reclaim-policies) |
| 3 | 📀 [Manage persistent volumes and persistent volume claims](#manage-persistent-volumes-and-persistent-volume-claims) |

---

### [Services & Networking](#4-services--networking-20) `20%`

> ![weight](https://img.shields.io/badge/Exam%20Weight-20%25-2ECC71?style=flat-square) &nbsp; 📖 [Study Notes](./study-notes/04-services-networking.md)

| # | Topic |
|---|-------|
| 1 | 🔗 [Understand connectivity between Pods](#understand-connectivity-between-pods) |
| 2 | 🛡️ [Define and enforce Network Policies](#define-and-enforce-network-policies) |
| 3 | 🔀 [Use ClusterIP, NodePort, LoadBalancer service types and endpoints](#use-clusterip-nodeport-loadbalancer-service-types-and-endpoints) |
| 4 | 🚪 [Use the Gateway API to manage Ingress traffic](#use-the-gateway-api-to-manage-ingress-traffic) |
| 5 | 🗺️ [Know how to use Ingress controllers and Ingress resources](#know-how-to-use-ingress-controllers-and-ingress-resources) |
| 6 | 🔍 [Understand and use CoreDNS](#understand-and-use-coredns) |

---

### [Troubleshooting](#5-troubleshooting-30) `30%`  Highest Weight

> ![weight](https://img.shields.io/badge/Exam%20Weight-30%25-E74C3C?style=flat-square) &nbsp; 📖 [Study Notes](./study-notes/05-troubleshooting.md)

> [!IMPORTANT]
> **Troubleshooting is worth 30% of your score** — the single largest domain. Dedicate at least one-third of your study time here.

| # | Topic |
|---|-------|
| 1 | 🖥️ [Troubleshoot clusters and nodes](#troubleshoot-clusters-and-nodes) |
| 2 | ⚙️ [Troubleshoot cluster components](#troubleshoot-cluster-components) |
| 3 | 📊 [Monitor cluster and application resource usage](#monitor-cluster-and-application-resource-usage) |
| 4 | 📋 [Manage and evaluate container output streams](#manage-and-evaluate-container-output-streams) |
| 5 | 🌐 [Troubleshoot services and networking](#troubleshoot-services-and-networking) |

---

## 1. Cluster Architecture, Installation & Configuration (25%)

Following are the subtopics under Cluster Architecture, Installation & Configuration

### Manage role based access control (RBAC).
> [RBAC](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55733398) | [Service Accounts](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55724447) | [Roles & ClusterRoles](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55997133) : Understand the difference between Roles (namespace level) and ClusterRoles (cluster level).

```bash
# Create a service account
k create sa <sa-name> -n <namespace>

# Create a role
k create role <role-name> --verb=<verbs> --resource=<resources> -n <namespace>

# Create rolebinding
k create rolebinding <binding-name> --role=<role-name> --user=<username> -n <namespace>

# Create a clusterrole
k create clusterrole <clusterrole-name> --verb=<verbs> --resource=<resources>

# Create clusterrolebinding
k create clusterrolebinding <binding-name> --clusterrole=<clusterrole-name> --user=<username>

# Check RBAC authorization
k auth can-i <verb> <resource> --as=<username>
```

### Prepare underlying infrastructure for installing a Kubernetes cluster.
> [Setup Virtual Machines](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60080222) : Ensure that each virtual machine (VM) meets the minimum system requirements for setting up a Kubernetes cluster.

> [Kubeadm Cluster Prerequisites](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60080223) : Ensure that all VMs can communicate with each other, as Kubernetes requires all nodes to have unrestricted communication for pod-to-pod networking.

> [Provision underlying infrastructure to deploy a Kubernetes cluster](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60080224) : Tools like VirtualBox, VMware, or KVM can be used to set up virtual machines locally and for cloud environments, consider providers like AWS, GCP, or Azure for flexibility and scalability.

### Multi Part Kubeadm Cluster Initialization
> [Kubeadm Cluster Bootstrap](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60080225) : Initialize a Kubernetes cluster using a multi-part kubeadm configuration file, customizing the Kubelet, Kube Proxy, and Scheduler settings.

```yaml
# Edit the config file (Sample Configuration)
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "172.30.1.2"
  bindPort: 6443
nodeRegistration:
  name: "controlplane"
  criSocket: "unix:///var/run/containerd/containerd.sock"
  imagePullPolicy: IfNotPresent

---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: "1.35.0"
controlPlaneEndpoint: "172.30.1.2:6443"
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  dnsDomain: "cluster.local"
imageRepository: "registry.k8s.io"
etcd:
  local:
    dataDir: "/var/lib/etcd"
controllerManager:
  extraArgs:
    - name: "node-cidr-mask-size"
      value: "24"
scheduler:
  extraArgs:
    - name: "leader-elect"
      value: "true"

---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: "systemd"
syncFrequency: "1m"
failSwapOn: false
rotateCertificates: true

---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
clusterCIDR: "10.244.0.0/16"
conntrack:
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: "1h"
  tcpEstablishedTimeout: "24h"
```

```bash
# Initialize the cluster using the config file
sudo kubeadm init --config=[CONFIG_FILE] --ignore-preflight-errors=NumCPU

# Configure the Kubectl access [Command will be shown in the output]
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install the CNI plugin
kubectl apply -f [CNI_URL]

# Join worker nodes [Command will be shown in the output]
ssh [WORKER_NODE]

kubeadm join ....
```

### Manage the lifecycle of Kubernetes clusters.
> [Perform Cluster Version upgrade Using Kubeadm](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55120133) : Managing the lifecycle involves upgrading clusters, managing control plane nodes, and ensuring consistency across versions.

### Use Helm and Kustomize to install cluster components.
> Helm : Helm makes it easier to package and deploy Kubernetes applications. Practice installing, upgrading, and uninstalling releases.

```bash
# Install a helm chart
helm install <release-name> <chart-name>

# List helm releases
helm list

# Upgrade a helm release
helm upgrade <release-name> <chart-name>

# Search for a chart
helm search repo <chart-name>

# Uninstall a helm release
helm uninstall <release-name>
```

> Kustomize : Start by creating a directory containing all the Kubernetes manifests you want to manage with Kustomize.

```bash
# Example directory structure
example-app/
  ├── deployment.yaml
  ├── service.yaml
  └── kustomization.yaml

# Use Kustomize to apply resources (pass the directory, not the file)
k apply -k ./example-app/
```

### Understand extension interfaces (CNI, CSI, CRI, etc.).
> Container Runtime Interface (CRI) : Kubernetes uses the CRI to communicate with container runtimes.

```bash
# Check container runtime
crictl info

# List all containers
crictl ps

# View specific container details
crictl inspect <container-id>

# View container logs
crictl logs <container-id>
```

> [Network Plugin](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60189043) : Kubernetes uses network plugins (CNI) to manage pod networking, get a good understanding of popular plugins like Calico, Flannel, and Weave Net, and understand the role of CNIs in providing network connectivity, security policies, and IPAM.

```bash
# List installed CNI plugins
ls /etc/cni/net.d/

# Install the Tigera Operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/operator-crds.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/tigera-operator.yaml

# Download the Calico Custom Resources
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/custom-resources.yaml

# Get the cluster Pod CIDR information
kubectl -n kube-system get pod -l component=kube-controller-manager -o yaml | grep -i cluster-cidr

# Modify the Custom Resource manifest with the cluster CIDR
vi custom-resource.yaml
```

```yaml
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
```

```bash
# Apply the Custom Resource manifest
k apply -f custom-resource.yaml

# Validate the Pod and Node status
k get po -A
k get no
```

> Container Storage Interface (CSI) for Kubernetes GA : The CSI is a standardized mechanism that allows storage providers to provide persistent storage support for Kubernetes.

```bash
# List CSI drivers
k get csidrivers
```

### Understand CRDs, install and configure operators.
> Custom Resources : CRDs allows you to extend Kubernetes APIs to create new kinds of Kubernetes objects beyond the built-in ones.

```bash
# List CRDs
k get crd

# Describe a CRD
k describe crd <crd-name>

# Delete a CRD instance
k delete <resource-name> <name>
```

> Operator pattern : The Operator pattern allows you to automate the lifecycle of applications running on Kubernetes by packaging operational knowledge into Kubernetes-native applications.

---

## 2. Workloads & Scheduling (15%)

Following are the subtopics under Workloads & Scheduling

### Understand deployments and how to perform rolling update and rollbacks.
> [Deployments](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55402667) : Understand rolling updates and rollbacks. Use `kubectl rollout history` to inspect revision history.

```bash
# Create deployment with 3 replicas
k create deploy <deployment-name> --image=<image-name> --replicas=3

# Create deployment manifest file
k create deploy <deployment-name> --image <image-name> --replicas=3 --dry-run=client -o yaml > deploy.yaml

# Scale deployment replicas
k scale deploy <deployment-name> --replicas=2

# Update container image in a deployment
k set image deploy <deployment-name> nginx=<image-name>

# Rollback to previous deployment version
k rollout undo deploy <deployment-name>

# View deployment rollout history
k rollout history deploy <deployment-name>

# Rollback to a specific revision
k rollout undo deploy <deployment-name> --to-revision=1

# Pause deployment rollout
k rollout pause deploy <deployment-name>

# Resume deployment rollout
k rollout resume deploy <deployment-name>

# Rollout & restart a deployment
k rollout restart deploy <deployment-name>
```

### Use ConfigMaps and Secrets to configure applications.
> [ConfigMaps](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55993034) : Use ConfigMaps to separate environment-specific configurations from the container image.

```bash
# Create configmap
k create cm <configmap-name>

# Create configmap manifest file
k create cm <configmap-name> --dry-run=client -o yaml > cm.yaml

# Create configmap from literal values
k create cm <configmap-name> --from-literal=<key1>=<value1> --from-literal=<key2>=<value2>

# Create configmap from a file
k create cm <configmap-name> --from-file=<file-name>

# Create an immutable configmap
k create cm <configmap-name> --from-literal=<key>=<value> --immutable
```

> [Secrets](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55993473) : Remember that Secrets are base64-encoded and not encrypted and they are for storing sensitive data.

```bash
# Create generic secret from literal values
k create secret generic <secret-name> --from-literal=<key1>=<value1> --from-literal=<key2>=<value2>

# Create TLS secret from certificate files
k create secret tls <secret-name> --cert=tls.crt --key=tls.key
```

### Configure workload autoscaling.
> [Autoscaling Workloads](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/58713870) : Practice setting up Horizontal Pod Autoscaler (HPA).

```bash
# Using autoscaling (--cpu-percent is required for HPA to function)
k autoscale deploy <deployment-name> --min=2 --max=5 --cpu-percent=80
```

### Understand the primitives used to create robust, self-healing, application deployments.
> Configure Pod Priorities using Priority Class to ensure mission critical applications are available and handled during resource crunch.

**Detailed Lesson:** [Pod Priority & Priority Class](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60175740)

Here is how you can create and apply Pod Priorities to a Deployment.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 100000
globalDefault: false
description: "High priority for important workloads"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      priorityClassName: high-priority
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

> Configure Liveness, Readiness and Startup Probes : Using liveness and readiness probes in your deployment ensure that your applications are self-healing and automatically recover from failures.

```yaml
# Startup probe
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 10

# Liveness probe
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  failureThreshold: 1
  periodSeconds: 10

# Readiness probe
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
```

### Configure Pod admission and scheduling (limits, node affinity, etc.).
> [Pods](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55219547) : Always remember that a Pod may contain one or more containers, and they share storage/network resources, making communication between containers in the same Pod fast and efficient.

```bash
# Create a Pod
k run <pod-name> --image=<image-name> --restart=Never

# Create a temporary interactive pod
k run -it <pod-name> --image=<image-name> --rm --restart=Never -- sh

# Delete pod immediately
k delete po <pod-name> --grace-period=0 --force
```

```yaml
# Pod resource limits
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

> [Static Pods](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55279551) : To create a static pod, place the manifest in /etc/kubernetes/manifests on the desired node.

```bash
# Static pod manifest path
/etc/kubernetes/manifests
```

> [Labels and Selectors](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55658123) : When using selectors, you can filter Kubernetes resources by these labels to perform operations like scaling or applying configuration changes.

```bash
# Add a label to a pod
k label pod <pod-name> <label-key>=<label-value>

# List pods with their labels
k get po --show-labels

# List pods with specific label
k get po --selector <label-key>=<label-value>

# Remove a label from a pod
k label po <pod-name> <label-key>-
```

> [Taints and Tolerations](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55659898) : Use taints on critical nodes like control plane nodes to prevent general-purpose workloads from being scheduled on them.

```bash
# Check taints on nodes
k describe no <node-name> | egrep "Name:|Taints:"

# Taint a node
k taint nodes <node-name> <key>=<value>:<effect>
```

```yaml
# Add toleration to a pod
tolerations:
- key: <key>
  operator: <operator>
  value: <value>
  effect: <effect>
  tolerationSeconds: <in seconds>
```

```bash
# Remove taint from a node
k taint no <node-name> <key>=<value>-
```

> [Node Name & Node Selector](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55686799) : Node Selectors are used to schedule pods onto specific nodes by using labels on the nodes.

```bash
# Label a node
k label no <node-name> <label-key>=<label-value>

# Remove labels from a node
k label no <node-name> <label-key>-
```

```yaml
# Use node selector on pod
nodeSelector:
  <label-key>: <label-value>
```

> [Node Affinity](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55687979) : Use node affinity to control the placement of your pods, ensuring that workloads are distributed efficiently across nodes as per their requirements.

```yaml
# Example Node affinity
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: <label-key>
          operator: In
          values:
          - <label-value>
```

### Using Init Containers in Pods
> [Init Containers](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55299962) : Use init containers to prepare the Pod before the main container runs.

```yaml
# Add init container section under the `spec` section.
initContainers:
  - name: write-ip
    image: busybox
    command: ["sh", "-c", "echo $MY_POD_IP > /web-content/ip.txt; echo 'Wrote the Pod IP to ip.txt'"]
    env:
    - name: MY_POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
```

> [Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) : Use admission controllers to enforce policies such as resource quotas, pod security policies, and image validation.

---

## 3. Storage (10%)

Following are the subtopics under Storage

### Implement storage classes and dynamic volume provisioning.
> [Storage Classes](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55786335) : Understand the difference between default storage class and other classes.

```yaml
# Example storage class manifest file
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

```bash
# List storageclasses
k get sc

# Describe storageclass
k describe sc <storageclass-name>
```

> Dynamic Volume Provisioning : Understand which type of persistent storage is supported (like AWS EBS, GCE Persistent Disks) and practice using them.

### Configure volume types, access modes and reclaim policies.

> [Volumes](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55791431) : Understand which type of persistent storage is supported (like AWS EBS, GCE Persistent Disks) and practice using them.

> [Persistent Volumes](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55792087) : Remember the different reclaim policies: Retain, Delete, and Recycle. Understand access modes like ReadWriteOnce, ReadOnlyMany.

```yaml
# Create a Persistent Volume
apiVersion: v1
kind: PersistentVolume
metadata:
  name: techiescamp-pv
spec:
  capacity:
    storage: 15Gi
  accessModes:
  - ReadWriteMany
  hostPath:
    path: /tmp/data
```

```bash
# List persistentvolume
k get pv

# Describe persistentvolume
k describe pv <persistentvolume-name>

# Delete persistentvolume
k delete pv <persistentvolume-name>

# List persistentvolumeclaim
k get pvc

# Describe persistentvolumeclaim
k describe pvc <persistentvolumeclaim-name>

# Delete persistentvolumeclaim
k delete pvc <persistentvolumeclaim-name>
```

### Manage persistent volumes and persistent volume claims.
> [Configure a Pod to Use a PersistentVolume for Storage](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55792290) : Practice creating a pod with persistent storage defined in a YAML manifest. Ensure familiarity with both bindings and mounting.

```yaml
# Example volume bindings and mounting (correct indentation)
volumeMounts:
- name: mysql-storage
  mountPath: /var/lib/mysql
volumes:
- name: mysql-storage
  persistentVolumeClaim:
    claimName: mysql-pvc
```

---

## 4. Services & Networking (20%)

Following are the subtopics under Services & Networking

### Understand connectivity between Pods.
> [Cluster Configurations](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55120218) : Use kubectl exec to test network connectivity between pods.

```bash
# Execute shell in a pod
k exec -it <pod-name> -- /bin/sh

# Execute shell in a specific container within a pod
k exec -it <pod-name> -c webserver -- sh

# Get pod IP addresses
k get po -o wide

# Check pod-to-pod connectivity
k exec <pod-name> -- curl <target-service-ip>:<port>

# Check network interfaces inside a pod
k exec <pod-name> -- ifconfig
```

### Define and enforce Network Policies.
> [Network Policies](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/57421520) : Practice setting up network policies to restrict traffic flow between pods.

```yaml
# Create a Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

```bash
# List network policies
k get netpol

# Describe network policies
k describe netpol <policy-name>
```

### Use ClusterIP, NodePort, LoadBalancer service types and endpoints.
> [Service](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55809546) : Practice exposing deployments using all types of services: ClusterIP, NodePort, and LoadBalancer.

```bash
# Expose deployment as a service
k expose deploy <deployment-name> --name=<service-name> --port=<port> --target-port=<container-port> --type=<service-type>

# List services
k get svc

# List service endpoints
k get ep
```

### Use the Gateway API to manage Ingress traffic.
> [Gateway API](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/61100920) : The Gateway API provides more flexibility and extensibility compared to traditional Ingress. Use it when you need advanced traffic routing, such as assigning multiple gateways with different capabilities to different services.

```yaml
# Create a Gateway
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: frontend-gateway
  namespace: frontend
spec:
  gatewayClassName: [GATEWAY_CLASS_NAME]
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: "[HOST_NAME]"
    tls:
      mode: Terminate
      certificateRefs:
        - kind: Secret
          name: [TLS_SECRET_NAME]

---
# Create a HTTPRoute to map the routing rules.
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
  namespace: frontend
spec:
  parentRefs:
    - name: [GATEWAY_NAME]
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: [SERVICE_NAME]
          port: 80
```

### Know how to use Ingress controllers and Ingress resources.
> [Ingress](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/56659356) : Practice creating Ingress resources with different rules to route traffic to services based on hostnames and paths. You can also define multiple services under a single Ingress resource by utilizing both path-based and host-based rules.

```yaml
# Example manifest file to create ingress object
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /examplepath
        pathType: Prefix
        backend:
          service:
            name: example
            port:
              number: 80
```

```bash
# List all ingress resources
k get ing

# Describe an ingress resource
k describe ing <ingress-name>
```

### Understand and use CoreDNS.
> [CoreDNS](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55120286) : CoreDNS is used for service discovery within the Kubernetes cluster. Familiarize yourself with modifying the Corefile configuration to add custom DNS behaviors like forwarding queries for specific domains outside the cluster.

```bash
# Get CoreDNS ConfigMap in the kube-system namespace
k get cm coredns -n kube-system

# Edit CoreDNS ConfigMap for custom DNS configurations
k edit cm coredns -n kube-system

# Get logs of CoreDNS pods
k logs -n kube-system -l k8s-app=kube-dns
```

---

## 5. Troubleshooting (30%)

### Troubleshoot cluster components.
> Troubleshooting kubectl : Make sure your kubectl is configured to connect to the correct cluster context.

> Troubleshooting kubeadm : Monitor control plane components such as API server, etcd, controller-manager for potential issues during the cluster lifecycle and make sure proper certificate expiration and connectivity between components.

```bash
# Cluster components manifest file location
/etc/kubernetes/manifests

# Check kubectl configuration
k config view

# Get logs of kubelet
journalctl -u kubelet

# Check status of kubelet
systemctl status kubelet

# Check status of API server
k get --raw /healthz
kubectl get pods -n kube-system -l tier=control-plane
```

### Monitor cluster and application resource usage.
> [Metrics Server](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/60080228) : Use kubectl top to monitor resource utilization.

```bash
# Get node CPU and memory usage
k top no

# Sort pods based on CPU utilization
k top po --sort-by=cpu

# Sort pods based on memory usage
k top po --sort-by=memory

# Get pod CPU and memory usage
k top po
```

### Manage and evaluate container output streams.
> Logging Architecture : Logs are vital for understanding what's happening inside containers. Use kubectl logs to access logs from running containers.

```bash
# Get logs of a pod
k logs <pod-name>

# Get logs of a multi container pod
k logs <pod-name> -c <container-name>

# Get live logs of a pod
k logs <pod-name> -f
```

### Troubleshoot services and networking.
> [Debugging a ReplicaSet](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55300118) | [Debug a Deployment](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55403687) : Practice using the describe and logs commands to inspect failed services or pods.

```bash
# Describe a pod
k describe pod <pod-name>

# Describe a service
k describe svc <service-name>

# Check recent events in the cluster
k get events --sort-by='.lastTimestamp'
```

---

## 📖 Exam References

<details>
<summary><strong>🎯 Exam Tips &amp; Strategy</strong></summary>

<br>

### Check Your Context — Every Single Question

```bash
kubectl config get-contexts
kubectl config use-context <required-context>
kubectl config set-context --current --namespace=<required-namespace>
```

### Imperative Commands (save time)

```bash
k run nginx --image=nginx --restart=Never
k create deployment nginx --image=nginx
k expose deployment nginx --port=80
k create configmap cm --from-literal=k=v
k create secret generic sec --from-literal=k=v
k create role r --verb=get --resource=pods
k scale deployment nginx --replicas=3
k set image deployment/nginx nginx=nginx:1.26
```

### Dry-run → Edit → Apply (for complex YAML)

```bash
k create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
vim deploy.yaml
k apply -f deploy.yaml
```

### Common Traps

| Trap | Prevention |
|------|-----------|
| Wrong namespace | Set `-n <namespace>` or `k config set-context --current --namespace=<ns>` |
| Wrong cluster context | Run `k config use-context <ctx>` before every task |
| Tabs in YAML | Always 2 spaces, never tabs |
| Not verifying work | After each task: `k get` / `k describe` to confirm |
| Static pod edits | Changes to `/etc/kubernetes/manifests/` auto-restart — wait for reload |
| Missing `--restart=Never` | Required for one-off pods |

### Last-Minute Checklist

- [ ] Practice switching contexts: `kubectl config use-context`
- [ ] Know how to drain/uncordon a node
- [ ] Review NetworkPolicy YAML syntax
- [ ] Review PV/PVC creation and binding
- [ ] Practice RBAC resources imperatively
- [ ] Know how to find and fix a broken kubelet
- [ ] Get comfortable with `kubectl explain`
- [ ] Practice `--dry-run=client -o yaml` for every resource type

> 📄 Full guide: [EXAM_TIPS.md](./EXAM_TIPS.md)

</details>

---

<details>
<summary><strong>📅 Exam Day Guide</strong></summary>

<br>

### Quick Stats

| Item | Detail |
|------|--------|
| **Duration** | 2 hours |
| **Tasks** | 15–20 performance-based |
| **Passing Score** | 66% |
| **Kubernetes Version** | v1.35 |
| **Results** | Emailed within 24 hours |
| **Retake** | 1 free retake included |

### First 5 Minutes

```bash
# Verify kubectl works
k version

# Speed shortcuts
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"

# Enable bash completion
source <(kubectl completion bash)
complete -F __start_kubectl k

# Configure vim
echo "set tabstop=2" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc
echo "set shiftwidth=2" >> ~/.vimrc
export KUBE_EDITOR=vim
```

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Close tab (Chrome) | `Ctrl+Alt+W` (**NOT** `Ctrl+W`) |
| Copy (terminal) | `Ctrl+Shift+C` |
| Paste (terminal) | `Ctrl+Shift+V` |
| Find in Firefox | `Ctrl+F` |
| Vim INSERT mode | `i` (INSERT key is disabled on remote desktop) |
| Exit Vim INSERT | `Esc` |

### Vim Quick Reference

```
i            → INSERT mode          :wq      → Save and quit
Esc          → COMMAND mode         :q!      → Quit without saving
dd           → Delete line          yy       → Copy line
p            → Paste                u        → Undo
gg / G       → Top / Bottom         /pattern → Search
:%s/old/new/g → Replace all         :set paste → Paste mode
```

### Time Management

| Domain | Weight | Suggested Time |
|--------|--------|---------------|
| Troubleshooting | 30% | ~36 min |
| Cluster Architecture | 25% | ~30 min |
| Services & Networking | 20% | ~24 min |
| Workloads & Scheduling | 15% | ~18 min |
| Storage | 10% | ~12 min |

**3-pass approach:** First pass (60 min) — easy wins. Second pass (45 min) — flagged questions. Buffer (15 min) — verify all.

> 📄 Full guide: [EXAM_DAY_GUIDE.md](./EXAM_DAY_GUIDE.md)

</details>

---

<details>
<summary><strong>❓ CKA FAQ</strong></summary>


**Q: What Kubernetes version is the CKA exam on in 2026?**

A: Kubernetes v1.35. This guide targets v1.35 specifically, matching the current exam environment.

**Q: What is the passing score for the CKA exam?**

A: 66%. Partial credit is awarded — incomplete answers still earn points.

**Q: How many questions are on the CKA exam?**

A: 15–20 performance-based tasks. No multiple choice. All hands-on in a live cluster.

**Q: Can I use kubectl documentation during the CKA exam?**

A: Yes. One browser tab is allowed: kubernetes.io/docs, kubernetes.io/blog, or helm.sh/docs.

**Q: How long is CKA certification valid?**

A: 2 years from the date you pass.

**Q: Does the CKA exam include a free retake?**

A: Yes. One free retake is included, and it must be used within 12 months of purchase.

**Q: What is the hardest domain on the CKA exam?**

A: Troubleshooting (30%) is the highest-weighted domain and most commonly causes candidates to fail. Invest at least one-third of your study time there.

**Q: How do I set up a local Kubernetes cluster for CKA practice?**

A: Use the Vagrant-based lab in `lab-setup/`. Supports Mac Silicon, Mac Intel, Windows, and Ubuntu Desktop. Each folder has its own README with setup steps.

**Q: What kubectl commands are allowed on the CKA exam?**

A: All kubectl commands. The exam is a live terminal — no restrictions on which commands you use. You can also use `vim`, `nano`, `curl`, `systemctl`, and `crictl`.


> 📄 Full FAQ: [FAQ.md](./FAQ.md)

</details>

---

<details>
<summary><strong>📝 Practice Questions</strong></summary>

<br>

35 exam-style scenario questions covering all 5 CKA domains. Try each before reading the solution.

### How to Use

1. Read the question carefully note the **namespace** and **cluster context**
2. Attempt the solution yourself
3. Reveal the solution and compare
4. If wrong, understand *why* before moving on

### Score Yourself

| Questions Solved | Result |
|-----------------|--------|
| 29–35 | Exam-ready 🟢 |
| 22–28 | Almost there 🟡 |
| 15–21 | More practice needed 🟠 |
| < 15  | Focus on fundamentals 🔴 |

> 📄 Full guide: [PRACTICE_QUESTIONS.md](./PRACTICE_QUESTIONS.md)

</details>

---

<details>
<summary><strong>🔧 Troubleshooting Guide</strong></summary>

<br>

Systematic debug playbooks for every layer of Kubernetes. Troubleshooting is **30% of the CKA exam**.

### Universal Debug Checklist

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

### Pod State Quick Reference

| State | Root Cause |
|-------|-----------|
| `Pending` | No schedulable node: resources, taints, affinity, PVC |
| `CrashLoopBackOff` | App crash — check logs + exit code |
| `OOMKilled` | Memory limit too low |
| `ImagePullBackOff` | Wrong image name/tag or missing registry secret |
| `Terminating` (stuck) | Finalizer blocking deletion |

> 📄 Full guide: [TROUBLESHOOTING_GUIDE.md](./TROUBLESHOOTING_GUIDE.md)

</details>

---

<details>
<summary><strong>🤝 Contributing</strong></summary>

<br>

Contributions are welcome. Please follow these guidelines.

- **Bug reports / corrections**: Open an issue describing the error and the correct information with a source link.
- **Content additions**: Open a pull request with your changes. Keep additions focused on CKA v1.35 exam scope.
- **Typo / formatting fixes**: Pull requests welcome, no issue needed.

### Pull Request Guidelines

1. Fork the repo and create a branch from `main`.
2. Keep each PR scoped to one topic or fix.
3. Verify all commands against Kubernetes v1.35.
4. Link to official Kubernetes docs or CNCF curriculum when adding new content.

> 📄 Full guide: [CONTRIBUTING.md](./CONTRIBUTING.md)

</details>

---

> ⭐ If this guide helped you, please star the repo!