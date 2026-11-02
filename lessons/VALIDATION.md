# Sandbox test results

Runtime checks ran on November 1, 2026. This report was finalized on November 2, 2026. These results cover the new labs and corrected examples, not every command in this repository.

## Test setup

- A separate local kind cluster, with three control-plane nodes, one worker, and an API load balancer.
- Kubernetes **v1.36.1**, kind **v0.32.0**, and Docker Desktop on Apple Silicon.
- A separate kubeconfig. No tests ran against the existing EKS cluster.
- NGINX Gateway Fabric **2.0.1**, using the chart already in this repository, with Gateway API CRDs **1.3.0**.
- Rancher Local Path Provisioner **0.0.37**.
- Traefik chart **42.2.0** was tested only for the separate Ingress lab. Gateway API uses NGINX Gateway Fabric.

## Results

| Check | Result |
|-------|--------|
| NGINX Gateway chart installation | Passed; controller and generated NGINX Deployment became ready |
| Gateway HTTP | Passed; returned the NGINX welcome page |
| Gateway HTTPS | Passed; curl trusted the test certificate and checked its hostname without `-k` |
| HTTPRoute status | Both HTTP and HTTPS parents reported `Accepted=True` and `ResolvedRefs=True` |
| Ingress routing | Passed; a request with `Host: test.local` reached the backend |
| EndpointSlices | Passed; the wrong selector removed backend addresses, and repairing it restored HTTP traffic |
| Pod Security Admission | Passed; baseline policy rejected a privileged Pod in a server dry-run |
| Immutable ConfigMap | Passed; creation worked and changing its data was rejected |
| Dynamic storage | Passed; PVC waited for a consumer, then bound; data survived Pod deletion and recreation |
| Storage cleanup | Passed; deleting the Pod and PVC removed the PV with the Delete policy |
| HPA | Partial: the command created the HPA and the workload reached its minimum of two replicas. CPU metrics and load-driven scaling were not verified because metrics-server could not finish starting |
| Gateway and Ingress cleanup | Partial: Gateway resources were deleted, but namespace cleanup was delayed by the unavailable metrics API. The full uninstall sequence was not confirmed |
| Control-plane failover | Passed; API readiness, ConfigMap creation, reads, and deletion worked while one control-plane container was stopped; the node was then restored |

## What these tests do not prove

- The sandbox used Kubernetes v1.36.1. This is not a v1.37 test or a claim of support for every Kubernetes version.
- kind prepared the control-plane nodes and load balancer. The separate Ubuntu VM, HAProxy installation, and manual kubeadm join steps were reviewed but were not run as a full VM lab.
- The sandbox used kind networking. Calico installation and nftables mode were not tested. The Calico change only fixes the downloaded filename used by the edit/apply commands.
- These are local lab checks, not production load, security, cloud load-balancer, or multi-platform tests.

## Remaining checks

Repeat CPU-metric and load-driven HPA scaling checks with a working Metrics Server, then run the complete cleanup sequence. The original sandbox was unavailable when this report was finalized, so these checks are still open. Do not treat this report as a full pass for every lab.
