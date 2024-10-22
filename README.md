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

```

### Configure volume types, access modes and reclaim policies.
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

Command Shortcuts:

```bash

```

### Manage persistent volumes and persistent volume claims.
- [Configure a Pod to Use a PersistentVolume for Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)



## Workloads & Scheduling (15%)
  - Understand deployments and how to perform rolling update and rollbacks.
      - [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
  - Use ConfigMaps and Secrets to configure applications.
      - [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
      - [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
  - Configure workload autoscaling.
      - [Autoscaling Workloads](https://kubernetes.io/docs/concepts/workloads/autoscaling/)
  - Understand the primitives used to create robust, self-healing, application deployments.
      - [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
  - Configure Pod admission and scheduling (limits, node affinity, etc.).
      - [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
      - [Admission Controllers Reference](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)

Command Shortcuts:

```bash

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
