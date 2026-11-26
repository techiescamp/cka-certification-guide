#!/bin/bash
#
# Common setup for all servers (Control Plane and Nodes)

set -euxo pipefail

# Kubernetes Variable Declaration
KUBERNETES_VERSION="v1.37"
CRIO_VERSION="v1.36"
CRICTL_VERSION="v1.37.0"
KUBERNETES_INSTALL_VERSION="1.37.0-1.1"

dns_ok() {
    getent hosts ports.ubuntu.com >/dev/null 2>&1
}

ensure_dns() {
    if dns_ok; then
        return 0
    fi

    echo "DNS resolution is failing — switching to public DNS resolvers"
    sudo mkdir -p /etc/systemd/resolved.conf.d
    cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/99-public-dns.conf
[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=9.9.9.9 8.8.4.4
EOF
    sudo systemctl restart systemd-resolved

    local attempt
    for attempt in {1..15}; do
        if dns_ok; then
            echo "DNS resolution restored"
            return 0
        fi
        sleep 2
    done

    echo "ERROR: DNS resolution still failing after applying public resolvers." >&2
    echo "Check the host network (a VPN or firewall can break Multipass NAT)," >&2
    echo "then re-run provision.sh." >&2
    return 1
}

ensure_dns

# Disable swap
sudo swapoff -a

# Keeps the swap off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg gnupg

# Install CRI-O Runtime
sudo apt-get update -y
sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates

sudo install -m 0755 -d /etc/apt/keyrings

# Add CRI-O apt repository
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    sudo tee /etc/apt/sources.list.d/cri-o.list

sudo apt-get update -y
sudo apt-get install -y cri-o

sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio.service

echo "CRI-O runtime installed successfully"

# Detect architecture for downloads (amd64 vs arm64)
ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64) CRICTL_ARCH="amd64" ;;
  arm64) CRICTL_ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Install crictl
curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${CRICTL_ARCH}.tar.gz"
sudo tar zxvf "crictl-${CRICTL_VERSION}-linux-${CRICTL_ARCH}.tar.gz" -C /usr/local/bin
rm -f "crictl-${CRICTL_VERSION}-linux-${CRICTL_ARCH}.tar.gz"

# Configure crictl to use CRI-O socket
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/crio/crio.sock
image-endpoint: unix:///run/crio/crio.sock
timeout: 10
debug: false
EOF

echo "crictl installed and configured successfully"

# Add Kubernetes apt repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubelet="$KUBERNETES_INSTALL_VERSION" kubectl="$KUBERNETES_INSTALL_VERSION" kubeadm="$KUBERNETES_INSTALL_VERSION"

# Prevent automatic updates for kubelet, kubeadm, and kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo apt-get update -y

# Install jq, a command-line JSON processor
sudo apt-get install -y jq

# Retrieve the local IP address of the primary interface and set it for kubelet
primary_if="$(ip --json route show default | jq -r '.[0].dev')"
local_ip="$(ip --json addr show "$primary_if" | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')"

# Write the local IP address to the kubelet default configuration file
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=$local_ip
EOF
