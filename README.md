# Ultimate Certified Kubernetes Administrator (CKA) Exam Preparation Guide - V1.31 (2025)

> This CKA learning path and guide is part of the [Complete CKA Certification Course](https://techiescamp.com/p/cka-complete-prep-course-practice-tests). 
> If you Looking for an organized way to learn Kubernetes and prepare for the CKA exam? Use code **DCUBE25** to get 25% OFF! Our course includes illustrations, hands-on exercises, real-world examples, and dedicated Discord support.

## Hit the Star! :star:

If you are planning to use this repo for reference, please hit the star. Thanks!

## CKA Exam Overview

The Certified Kubernetes Administrator (CKA) exam has a duration of 2 hours.
To pass the exam, candidates need to achieve a score of at least 66%.
The exam will be on Kubernetes version 1.31.
Once the certificate is earned, the CKA certification remains valid for 2 years. The cost to take the exam is $395 USD.

>**Important Note:** This guide is based on the new CKA syllabus. You can read more about the exam changes here [CKA Exam Changes](https://blog.techiescamp.com/cka-exam-updates/)

## CKA Exam Coupon (30% Off Exclusive Discount)

To save on CKA exam registration, use the following coupon code.

**Coupon:** Use code **DCUBE30** at [kube.promo/cka](https://kube.promo/cka)

Use code **DCUBE30** to save 40% on folowing bundles.

- KCNA + KCSA + CKA + CKAD + CKS (40% Savings): [kube.promo/kubestronaut](https://kube.promo/kubestronaut)
- CKA + CKAD + CKS Exam bundle (40% Savings): [kube.promo/k8s-bundle](https://kube.promo/k8s-bundle)
- CKA + CKS Bundle (40% Savings) [kube.promo/bundle](https://kube.promo/bundle)

>**Important Note:** If you're planning to take the Certified Kubernetes Administrator (CKA) exam, be aware that the syllabus is changing soon. If you want to give the CKA exam before the syllabus change on February 10th, dont delay booking your CKA Exam.  Plan and book your exam as early as possible to avoid last-minute slot issues.

## Table of Contents

1. [Cluster Architecture, Installation & Configuration (25%)](#1-cluster-architecture-installation--configuration-25)
   - [Manage role based access control (RBAC)](#manage-role-based-access-control-rbac)
   - [Prepare underlying infrastructure for installing a Kubernetes cluster](#prepare-underlying-infrastructure-for-installing-a-kubernetes-cluster)
   - [Create and manage Kubernetes clusters using kubeadm](#create-and-manage-kubernetes-clusters-using-kubeadm)
   - [Manage the lifecycle of Kubernetes clusters](#manage-the-lifecycle-of-kubernetes-clusters)
   - [Use Helm and Kustomize to install cluster components](#use-helm-and-kustomize-to-install-cluster-components)
   - [Understand extension interfaces (CNI, CSI, CRI, etc.)](#understand-extension-interfaces-cni-csi-cri-etc)
   - [Understand CRDs, install and configure operators](#understand-crds-install-and-configure-operators)

2. [Workloads & Scheduling (15%)](#2-workloads--scheduling-15)
   - [Understand deployments and how to perform rolling update and rollbacks](#understand-deployments-and-how-to-perform-rolling-update-and-rollbacks)
   - [Use ConfigMaps and Secrets to configure applications](#use-configmaps-and-secrets-to-configure-applications)
   - [Configure workload autoscaling](#configure-workload-autoscaling)
   - [Understand the primitives used to create robust, self-healing, application deployments](#understand-the-primitives-used-to-create-robust-self-healing-application-deployments)
   - [Configure Pod admission and scheduling (limits, node affinity, etc.)](#configure-pod-admission-and-scheduling-limits-node-affinity-etc)

3. [Storage (10%)](#3-storage-10)
   - [Implement storage classes and dynamic volume provisioning](#implement-storage-classes-and-dynamic-volume-provisioning)
   - [Configure volume types, access modes and reclaim policies](#configure-volume-types-access-modes-and-reclaim-policies)
   - [Manage persistent volumes and persistent volume claims](#manage-persistent-volumes-and-persistent-volume-claims)

4. [Services & Networking (20%)](#4-services--networking-20)
   - [Understand connectivity between Pods](#understand-connectivity-between-pods)
   - [Define and enforce Network Policies](#define-and-enforce-network-policies)
   - [Use ClusterIP, NodePort, LoadBalancer service types and endpoints](#use-clusterip-nodeport-loadbalancer-service-types-and-endpoints)
   - [Use the Gateway API to manage Ingress traffic](#use-the-gateway-api-to-manage-ingress-traffic)
   - [Know how to use Ingress controllers and Ingress resources](#know-how-to-use-ingress-controllers-and-ingress-resources)
   - [Understand and use CoreDNS](#understand-and-use-coredns)

5. [Troubleshooting (30%)](#5-troubleshooting-30)
   - [Troubleshoot clusters and nodes](#troubleshoot-clusters-and-nodes)
   - [Troubleshoot cluster components](#troubleshoot-cluster-components)
   - [Monitor cluster and application resource usage](#monitor-cluster-and-application-resource-usage)
   - [Manage and evaluate container output streams](#manage-and-evaluate-container-output-streams)
   - [Troubleshoot services and networking](#troubleshoot-services-and-networking)

## CKA Exam Detailed Study Guide & References

CKA Certification Exam has the following key domains:

## 1. Cluster Architecture, Installation & Configuration (25%)

Following are the subtopics under Cluster Architecture, Installation & Configuration

### Manage role based access control (RBAC).
> [RBAC](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55733267) | [Service Accounts](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55724447) | [Roles & ClusterRoles](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55997133) : Understand the difference between Roles (namespace level) and ClusterRoles (cluster level).

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
> [Setup Virtual Machines](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/54923684) : Ensure that each virtual machine (VM) meets the minimum system requirements for setting up a Kubernetes cluster.

> [Kubeadm Cluster Prerequisites](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55288352) : Ensure that all VMs can communicate with each other, as Kubernetes requires all nodes to have unrestricted communication for pod-to-pod networking.

> [Provision underlying infrastructure to deploy a Kubernetes cluster](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55287065) : Tools like VirtualBox, VMware, or KVM can be used to set up virtual machines locally and for cloud environments, consider providers like AWS, GCP, or Azure for flexibility and scalability.

### Create and manage Kubernetes clusters using kubeadm.
> [Cluster Setup](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55288346) : kubeadm is a tool used for easy cluster bootstrap, be familiar with creating a cluster control plane node and adding worker nodes.

```bash
# Set Up kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
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

# Install helm chart
helm install <release-name> <chart-name>

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

# Use Kustomize to apply resources
k apply -k kustomization.yaml

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

> [Network Plugin](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55287071) : Kubernetes uses network plugins (CNI) to manage pod networking, get a good understanding of  popular plugins like Calico, Flannel, and Weave Net, and understand the role of CNIs in providing network connectivity, security policies, and IPAM.

```bash
# List installed CNI plugins
ls /etc/cni/net.d/
```

> Container Storage Interface (CSI) for Kubernetes GA : The CSIs is a standardized mechanism that allows storage providers to provide persistent storage support for Kubernetes.

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

# Delete a CRD
k delete <resource-name> <name>

```

> Operator pattern : The Operator pattern allows you to automate the lifecycle of applications running on Kubernetes by packaging operational knowledge into Kubernetes-native applications.

## 2. Workloads & Scheduling (15%)

Following are the subtopics under Workloads & Scheduling

### Understand deployments and how to perform rolling update and rollbacks.
> [Deployments](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55402667) : Understand the use of --record for version history, which is crucial for rollbacks.

```bash
# Create deployment with 3 replicas
k create deploy <deployment-name> --image=<image-name> --replicas=3

# Create deployment manifest file
k create deploy <deployment-name> --image <image-name> --replicas=3  --dry-run=client -o yaml > deploy.yaml

# List deployment
k get deploy

# Check replicaSet
k get rs

# Describe the deployment
k describe deploy <deployment-name>

# Scale deployment replicas
k scale deploy <deployment-name> --replicas=2

# View Deployments Manifest file
k get deploy <deployment-name> -o yaml

# Update container image in a deployment
k set image deploy <deployment-name> nginx=<image-name> --record

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

# Delete deployment
k delete deploy <deployment-name>
```

### Use ConfigMaps and Secrets to configure applications.
> [ConfigMaps](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55993034) : Use ConfigMaps to separate environment-specific configurations from the container image.

```bash
# Create configmap
k create cm <configmap-name>

# Edit the configmap
k edit cm <configmap-name>

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
> Autoscaling Workloads : Practice setting up Horizontal Pod Autoscaler (HPA).

```bash
# Using autoscaling
k autoscale deploy <deployment-name> --min=2 --max=5
```

### Understand the primitives used to create robust, self-healing, application deployments.
> Configure Pod Priorities using Priority Class to ensure mission critial applications are available and handled during resource crunch.

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

```bash
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
k delete po <pod-name> --grace-period 0 --force

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

> [Taints and Tolerations](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55659898) : Use taints on critical nodes like control plane nodes or nodes to prevent general-purpose workloads from being scheduled on them.

```bash
# Check taints on nodes
k describe no <node-name> | egrep "Name:|Taints:"

# Taint a node
k taint nodes <node-name> <key>=<value>:<effect>

# Add toleration to a pod
tolerations:
- key: <key>
  operator: <operator>
  value: <value>
  effect: <effect>
  tolerationSeconds: <in seconds>

# Remove taint from a node
k taint no <node-name> <key>=<value>-

```

> [Node Name & Node Selector](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55686799) : Node Selectors are used to schedule pods onto specific nodes by using labels on the nodes.

```bash
# Label a node
k label no <pod-name> <label-key>=<label-value>

# Use node selector on pod
nodeSelector:
  <label-key>: <label-value>

# Remove labels from a node
k label no <pod-name> <label-key>-

```

[Node Affinity](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55687979) : Use node affinity to control the placement of your pods, ensuring that workloads are distributed efficiently across nodes as per there requirements.

```bash
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

> [Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) : Use admission controllers to enforce policies such as resource quotas, pod security policies, and image validation.

## 3. Storage (10%)

Following are the subtopics under Storage

### Implement storage classes and dynamic volume provisioning.
> [Storage Classes](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55786335) : Understand the difference between default storage class and other classes

```bash
# Example storage class manifest file
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete

# List storageclasses
k get sc

# Describe storageclass
k describe sc <storageclass-name>

```

> Dynamic Volume Provisioning : Understand which type of persistent storage is supported (like AWS EBS, GCE Persistent Disks) and practice using them.

### Configure volume types, access modes and reclaim policies.

> [Volumes](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55791431) : Understand which type of persistent storage is supported (like AWS EBS, GCE Persistent Disks) and practice using them.

> [Persistent Volumes](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55792087) : Remember to know the different reclaim policies: Retain, Delete, and Recycle. Understand access modes like ReadWriteOnce, ReadOnlyMany.

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

```bash
# Example volume bindings and mounting
volumeMounts:
- name: mysql-storage
  mountPath: /var/lib/mysql
volumes:
- name: mysql-storage
persistentVolumeClaim:
  claimName: mysql-pvc
```

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

```bash
# List network policies
k get netpol

# Description network policies
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
> Gateway API : The Gateway API provides more flexibility and extensibility compared to traditional Ingress. Use it when you need advanced traffic routing, such as assigning multiple gateways with different capabilities to different services.

### Know how to use Ingress controllers and Ingress resources.
> [Ingress](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/56659356) : Practice creating Ingress resources with different rules to route traffic to services based on hostnames and paths, you can also define multiple services under a single Ingress resource by utilizing both path-based and host-based rules.

```bash
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

## 5. Troubleshooting (30%)

Following are the subtopics under Troubleshooting

### Troubleshoot clusters and nodes.
> Troubleshooting Clusters : When draining a node, use --ignore-daemonsets to safely move workloads that can be moved while ignoring daemonsets.

```bash
# List all available nodes
k get no

# Describe nodes
k describe no <node-name>

# Drain a node
k drain <node-name> --ignore-daemonsets

# Cordon/uncordon a node
k cordon <node-name>
k uncordon <node-name>

```

### Troubleshoot cluster components.
> Troubleshooting kubectl : Make sure your kubectl is configured to connect to the correct cluster context.

> Troubleshooting kubeadm : Monitor control plane components such as API server, etcd, controller-manager for potential issues during the cluster lifecycle and make sure proper certificate expiration and connectivity between components.

```bash
# Cluster components manifest file location
/etc/kubernetes/manifests

# Check kubectl configuration
k config view

# Get logs of kubectl
journalctl -u kubelet

# Check status of kubectl
k get --raw /healthz

# Check status of API server
k get componentstatuses

```

### Monitor cluster and application resource usage.
> [Metrics Server](https://techiescamp.com/courses/certified-kubernetes-administrator-course/lectures/55287074) : Use kubectl top to monitor resource utilization.

```bash
# Get no cpu and memory usage
k top no

# Sort pods based on cpu utilization
k top po --sort-by=cpu

# Sort pods based on memory usage
k top po --sort-by=memory

# Get pod cpu and memory usage
k top pod

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
k get events
```
# Kubectl Tips for CKA Exam

The `kubectl` command-line tool is your gateway to interacting with Kubernetes clusters. In the CKA exam, efficiency and accuracy are key, and mastering `kubectl` can save you valuable time. Below, I’ll share some `kubectl` tips, tricks, and commands that you can use to navigate through the tasks more easily.

## 1. Use Aliases for Speed
Typing `kubectl` repeatedly can be a bit time-consuming. You can set up an alias to save time:

```bash
alias k="kubectl"
```

With this, you can just use `k` instead of typing `kubectl`. For example:

```bash
k get pods
```

## 2. Use `-o` for Output Customization
The `-o` flag allows you to format the output in different ways. This is particularly helpful when you need specific details:

- Get pod details in YAML format:
  ```bash
  kubectl get pod my-pod -o yaml
  ```
- Get only the names of all pods:
  ```bash
  kubectl get pods -o name
  ```
- Get pod details in JSON format (handy if you need to extract specific data):
  ```bash
  kubectl get pod my-pod -o json
  ```

## 3. Quickly Edit Resources
You may need to edit resources during the exam. Instead of recreating a resource, you can edit it directly:

```bash
kubectl edit deployment my-deployment
```

This command opens the resource configuration in your default text editor, where you can make changes on the fly.

## 4. Use `--dry-run` for Testing
The `--dry-run` flag is great for checking what a command will do before actually applying it. This is helpful in avoiding mistakes:

- Test creating a pod without actually creating it:
  ```bash
  kubectl run nginx --image=nginx --dry-run=client -o yaml
  ```
  
  This command will output the YAML configuration for the pod without deploying it, which you can redirect to a file if needed.

## 5. Generators for Quick YAML Files
You can generate basic YAML files with `kubectl` and redirect the output to a file for further modifications:

- Generate a deployment YAML:
  ```bash
  kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml
  ```

## 6. Describe for Detailed Debugging
The `kubectl describe` command is useful when debugging issues, as it provides detailed information about resources:

```bash
kubectl describe pod my-pod
```

This command can help you find events or errors associated with a pod, such as crash loops or insufficient resources.

## 7. Use `-l` for Label Selection
Label selectors allow you to filter resources easily. This is helpful for working with groups of resources:

- Get all pods with a specific label:
  ```bash
  kubectl get pods -l app=nginx
  ```

- Delete resources with a specific label:
  ```bash
  kubectl delete pods -l env=testing
  ```

## 8. Shortcuts for Common Operations
`kubectl` has built-in shortcuts for common resource types, which can save you typing:

- `po` for pods
  ```bash
  kubectl get po
  ```
- `deploy` for deployments
  ```bash
  kubectl get deploy
  ```
- `svc` for services
  ```bash
  kubectl get svc
  ```

## 9. Use `kubectl explain` to Understand Resource Definitions
If you’re unsure about the structure of a resource, `kubectl explain` can be your best friend:

```bash
kubectl explain pod.spec.containers
```

This command will provide you with detailed information about what each field does, which is helpful when writing YAML files.

## 10. Context and Namespace Management
Switching between different namespaces and contexts can be common in the exam:

- Set a default namespace to avoid typing `-n` every time:
  ```bash
  kubectl config set-context --current --namespace=my-namespace
  ```

- View the current context:
  ```bash
  kubectl config current-context
  ```

## 11. Imperative Commands for Quick Changes
Imperative commands are great for making quick changes without writing YAML files:

- Scale a deployment:
  ```bash
  kubectl scale deployment nginx --replicas=3
  ```
- Expose a deployment as a service:
  ```bash
  kubectl expose deployment nginx --port=80 --target-port=8080 --type=NodePort
  ```

## Final Tip: Practice, Practice, Practice
The more comfortable you are with `kubectl`, the easier the exam will be. Set up a small Kubernetes cluster using tools like Minikube or Kind and practice these commands until they become second nature.

Good luck with your CKA exam preparation! Remember, speed and accuracy come with consistent practice.


