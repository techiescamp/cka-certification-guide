# Ultimate Certified Kubernetes Administrator (CKA) Preparation Guide - V1.30 (2024)

This guide is part of the [Complete CKA Certification Course](https://techiescamp.com/p/certified-kubernetes-administrator-course)

---
## Exam Details

The Certified Kubernetes Administrator (CKA) exam has a duration of 2 hours.
To pass the exam, candidates need to achieve a score of at least 66%.
The exam will be on Kubernetes version 1.30.
Once the certificate is earned, the CKA certification remains valid for 2 years. The cost to take the exam is $395 USD.

---
## 📘 CKA Overview

CKA Certification Exam has the following key domains:

## Storage (10%)

Following are the subtopics under Storage

### Implement storage classes and dynamic volume provisioning.
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Dynamic Volume Provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/)

Command Shortcuts:

```bash
# List storageclasses
k get sc

# Describe storageclass
k describe sc <storageclass-name>

```

### Configure volume types, access modes and reclaim policies.
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

Command Shortcuts:

```bash
# List persistentvolume
k get pv

# Describe persistentvolume
k describe pv <persistentvolume-name>

# Delete persistentvolume
k delete pv <persistentvolume-name>
```

### Manage persistent volumes and persistent volume claims.
- [Configure a Pod to Use a PersistentVolume for Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

Command Shortcuts:

```bash
# List persistentvolumeclaim
k get pvc

# Describe persistentvolumeclaim
k describe pc <persistentvolumeclaim-name>

# Delete persistentvolumeclaim
k delete pvc <persistentvolumeclaim-name>
```

## Workloads & Scheduling (15%)

Following are the subtopics under Workloads & Scheduling

### Understand deployments and how to perform rolling update and rollbacks.
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

Command Shortcuts:

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
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)

```bash
# Create configmap
k create cm <configmap-name>

# Edit the configmap
k edit cm <configmap-name>

# Create configmap manifest file
k create cm <configmap-name> --dry-run=client -o yaml > cm.yaml

# Create configmap from literal values
k create cm mycm --from-literal=api=api.techiescamp.com --from-literal=backend_url=api.backend.techiescamp.com

# Create configmap from a file
k create cm app-config --from-file=app.properties

```

- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

Command Shortcuts:

```bash
# Create generic secret from literal values
k create secret generic db-secret --from-literal=username=admin --from-literal=password=secret

# Create TLS secret from certificate files
k create secret tls nginx-tls --cert=tls.crt --key=tls.key

```

### Configure workload autoscaling.
- [Autoscaling Workloads](https://kubernetes.io/docs/concepts/workloads/autoscaling/)


### Understand the primitives used to create robust, self-healing, application deployments.
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)


### Configure Pod admission and scheduling (limits, node affinity, etc.).
- [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- [Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)

Command Shortcuts:

```bash
# Create a Pod
k run mypod --image=<image-name> --restart=Never
```

## Services & Networking (20%)
  - Understand connectivity between Pods.
      - [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
  - Define and enforce Network Policies.
      - [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
  - Use ClusterIP, NodePort, LoadBalancer service types and endpoints.
      - [Service](https://kubernetes.io/docs/concepts/services-networking/service/)
  - Use the Gateway API to manage Ingress traffic.
      - [Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/)
  - Know how to use Ingress controllers and Ingress resources.
      - [Ingress Controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
      - [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
  - Understand and use CoreDNS.
      - [Using CoreDNS for Service Discovery](https://kubernetes.io/docs/tasks/administer-cluster/coredns/)

Command Shortcuts:

```bash

```

## Troubleshooting (30%)
  - Troubleshoot clusters and nodes.
      - [Troubleshooting Clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)
  - Troubleshoot cluster components.
      - [Troubleshooting kubectl](https://kubernetes.io/docs/tasks/debug/debug-cluster/troubleshoot-kubectl/)
      - [Troubleshooting kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/)
  - Monitor cluster and application resource usage.
      - [Tools for Monitoring Resources](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/)
  - Manage and evaluate container output streams.
      - [Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
  - Troubleshoot services and networking.
      - [Debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/)

Command Shortcuts:

```bash

```

## Cluster Architecture, Installation & Configuration (25%)
  - Manage role based access control (RBAC).
      - [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
  - Prepare underlying infrastructure for installing a Kubernetes cluster.
      - [Overview](https://kubernetes.io/docs/concepts/overview/)
  - Create and manage Kubernetes clusters using kubeadm.
      - [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
  - Manage the lifecycle of Kubernetes clusters.
      - [Upgrading kubeadm clusters](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)
  - Use Helm and Kustomize to install cluster components.
      - [Declarative Management of Kubernetes Objects Using Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
  - Understand extension interfaces (CNI, CSI, CRI, etc.).
      - [Container Runtime Interface (CRI)](https://kubernetes.io/docs/concepts/architecture/cri/)
      - [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
      - [Container Storage Interface (CSI) for Kubernetes GA](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/)
  - Understand CRDs, install and configure operators.
      - [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
      - [Operator pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)

Command Shortcuts:

```bash

```
