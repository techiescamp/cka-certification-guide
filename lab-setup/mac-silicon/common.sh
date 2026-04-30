#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)
# Ref: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
# Ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
set -euxo pipefail

# Kubernetes Variable Declaration
KUBERNETES_VERSION="v1.36"
CRICTL_VERSION="v1.36.0"
KUBERNETES_INSTALL_VERSION="1.36.0-1.1"

# ============================================================
# 1. Disable swap
# ============================================================
sudo swapoff -a

# Keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

sudo apt-get update -y

# ============================================================
# 2. Kernel modules required by Kubernetes networking
# ============================================================
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl params required by setup — persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# ============================================================
# 3. Install containerd runtime
# Ref: https://docs.docker.com/engine/install/ubuntu/
# ============================================================
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y containerd.io

sudo systemctl daemon-reload
sudo systemctl enable containerd --now

echo "Containerd runtime installed successfully"

# ============================================================
# 4. Configure containerd — enable SystemdCgroup
# ============================================================
# Generate the default containerd configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Enable SystemdCgroup (required for Kubernetes)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd

# ============================================================
# 5. Install crictl (CRI CLI tool)
# ============================================================
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-${CRICTL_VERSION}-linux-amd64.tar.gz

# ============================================================
# 6. Add Kubernetes APT repository (pkgs.k8s.io — official)
# Ref: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# NOTE: The legacy apt.kubernetes.io repo is deprecated and REMOVED.
# ============================================================
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Create keyrings directory if it doesn't exist (required on Ubuntu < 22.04)
sudo mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# ============================================================
# 7. Install kubelet, kubeadm, kubectl
# ============================================================
sudo apt-get update -y
sudo apt-get install -y \
  kubelet="${KUBERNETES_INSTALL_VERSION}" \
  kubeadm="${KUBERNETES_INSTALL_VERSION}" \
  kubectl="${KUBERNETES_INSTALL_VERSION}"

# Prevent automatic upgrades (critical — never auto-upgrade k8s components)
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start kubelet
sudo systemctl enable kubelet --now

echo "Kubernetes components installed successfully"
echo "kubelet: $(kubelet --version)"
echo "kubeadm: $(kubeadm version -o short)"
echo "kubectl: $(kubectl version --client -o yaml | grep gitVersion)"
root@controlplane:/home/vagrant# 