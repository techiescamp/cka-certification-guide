# Highly available control-plane lab

Use VMs created only for this lab: three control-plane nodes (`cp1`–`cp3`), a worker, and a TCP load balancer. On each Kubernetes node, install a supported container runtime and matching versions of kubeadm, kubelet, and kubectl. Give each node a unique hostname, sync its clock, and open the required Kubernetes ports. Use the [kubeadm prerequisites](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). This setup is different from the repository's single-control-plane Vagrant labs.

## Shared endpoint

Set up DNS or hosts entries so `api.cka.test` points to your load balancer from every node and the computer you use to manage the cluster. Replace the example IPs below with your VM addresses. On a separate Ubuntu load-balancer VM, install HAProxy (`sudo apt-get install -y haproxy`) and add these sections to `/etc/haproxy/haproxy.cfg`:

```text
frontend kubernetes_api
    bind *:6443
    mode tcp
    default_backend kubernetes_controlplanes

backend kubernetes_controlplanes
    mode tcp
    balance roundrobin
    option tcp-check
    server cp1 192.168.201.10:6443 check
    server cp2 192.168.201.11:6443 check
    server cp3 192.168.201.12:6443 check
```

Run `sudo haproxy -c -f /etc/haproxy/haproxy.cfg`, then `sudo systemctl restart haproxy`. Allow traffic from the nodes to port 6443. One HAProxy VM lets you test what happens when a control-plane node fails. If that HAProxy VM fails, API access also stops. For production, use multiple load balancers or a managed HA endpoint.

## Initialize and join

On `cp1`, choose a Pod CIDR supported by your CNI that does not overlap with your node or Service networks:

```bash
sudo kubeadm init --control-plane-endpoint api.cka.test:6443 \
  --upload-certs --pod-network-cidr=10.244.0.0/16
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
```

Install the CNI using the README's Calico instructions, setting its IP pool CIDR to the same value. Copy the **control-plane join command** shown by kubeadm to `cp2` and then `cp3`:

```bash
# Replace every placeholder with values from your own initialization output.
sudo kubeadm join api.cka.test:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash> \
  --control-plane --certificate-key <certificate-key>
```

Join the worker with the worker join command (no `--control-plane` or certificate key). Certificate uploads expire after two hours; generate a fresh key on `cp1` with `sudo kubeadm init phase upload-certs --upload-certs` if needed. Generate a fresh token/join command with `sudo kubeadm token create --print-join-command`. Keep join credentials private.

This creates **stacked etcd**, with an etcd member on each control-plane node. **External etcd** runs on three separate nodes. You must configure its endpoints and client certificates. This keeps etcd separate from control-plane node failures, but needs more machines. Do not point this stacked example at external etcd without following the official external-etcd setup.

## Verify and simulate failure

From `cp1`, check all nodes are Ready and three etcd Pods are healthy:

```bash
kubectl get nodes -o wide
kubectl -n kube-system get pods -l component=etcd -o wide
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
kubectl get --raw='/readyz?verbose'
```

The server must be `https://api.cka.test:6443`. Power off **only cp3** using your VM manager. From `cp1`, repeat the readiness request and test an API write:

```bash
kubectl create configmap ha-check --from-literal=result=available
kubectl get configmap ha-check
kubectl delete configmap ha-check
```

Requests should still succeed through the load balancer; `cp3` eventually becomes NotReady. Two healthy etcd members provide the majority (quorum) needed to keep the cluster working. Stopping kubelet alone does not fully simulate a node failure because existing static-Pod containers may keep running. Restore `cp3`, wait for it to become Ready, and verify its etcd Pod before any further failure test.

## Cleanup

Delete only the VMs created for this lab and remove the lab DNS/hosts entry. Do not run reset or failure commands on an existing shared cluster.

Reference: [kubeadm HA setup and topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/).
