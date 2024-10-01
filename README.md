# Ultimate Certified Kubernetes Administrator (CKA) Preparation Guide - V1.30 (2024)

This guide is part of the [Complete CKA Certification Course](https://techiescamp.com/p/certified-kubernetes-administrator-course)

---

## 📘 Course Overview

This course is covering the following key domains:

- **Storage (10%)**
  - Understand storage classes, persistent volumes, and claims.
  - Learn about volume modes, access modes, and reclaim policies.
  - Configure applications with persistent storage.

- **Troubleshooting (30%)**
  - Evaluate cluster and node logging.
  - Monitor applications and manage container logs.
  - Troubleshoot application failures, cluster component issues, and networking problems.

- **Workloads & Scheduling (15%)**
  - Manage deployments, perform rolling updates, and rollbacks.
  - Utilize ConfigMaps, Secrets, and understand resource limits.
  - Explore manifest management and common templating tools.

- **Cluster Architecture, Installation & Configuration (25%)**
  - Manage role-based access control (RBAC).
  - Install and manage highly-available Kubernetes clusters.
  - Perform version upgrades and implement etcd backups and restores.

- **Services & Networking (20%)**
  - Configure host networking and understand connectivity between Pods.
  - Explore ClusterIP, NodePort, LoadBalancer, Ingress, CoreDNS, and CNI plugins.

## 📚 Course Curriculum

The course is divided into multiple modules, each focusing on a specific area of Kubernetes administration. Below is a snapshot of what you’ll learn in each module:

### Cluster Setup
- **Introduction** to setting up a Kubernetes cluster using Kubeadm.
- **Provision infrastructure** and install a basic cluster.
- **Join worker nodes** and deploy the network plugin.
- **Deploy Metrics Server** and validate the cluster.

### Cluster Configurations
- **Static Pod Manifests** and API Server configurations.
- **ETCD Configurations** and TLS Certificates management.
- **Perform Cluster Version Upgrade** using Kubeadm.
- **ETCD Backup & Restore** using etcdctl.

### Pods
- **Create Pods** using imperative and declarative commands.
- Work with **Multi Container Pods** and **Init Containers**.
- **Static Pods** creation and management.

### Deployments
- **Create Deployments** and perform rolling updates and rollbacks.
- **Manage ReplicaSets, DaemonSets, Jobs, and CronJobs**.
- **Scenario-based exercises** to solidify your understanding.

### RBAC (Role-Based Access Control)
- **Authentication & Authorization** methods.
- **Create Roles, ClusterRoles, and Bindings**.
- **Scenarios** to implement RBAC in real-world projects.

### Persistent Volumes & Storage Classes
- **Work with Persistent Volumes, Claims, and Storage Classes**.
- **Volume Subpath** and **mounting volumes** into Pods.
- **Scenarios** to set up persistent storage for applications.

### Services
- **Kubernetes Services** and their types (ClusterIP, NodePort, LoadBalancer).
- **DNS-based Service Discovery** and **ExternalName Service**.
- **Ingress Controllers** and **CoreDNS** configuration.


