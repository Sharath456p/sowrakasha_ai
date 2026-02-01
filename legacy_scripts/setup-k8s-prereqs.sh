#!/bin/bash
set -e

# The Nodes we created
NODES=("k8s-master" "k8s-worker-1" "k8s-worker-2")

echo "🔧 Preparing Nodes for Kubernetes (This replaces the Cloud Provider magic)..."

for NODE in "${NODES[@]}"; do
    echo "=================================================="
    echo "🛠️  Configuring $NODE..."
    echo "=================================================="

    # 1. Disable Swap (Kubernetes fails if swap is on)
    echo "   [1/5] Disabling Swap..."
    limactl shell $NODE sudo swapoff -a
    limactl shell $NODE sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # 2. Network Prerequisites (Kernel Modules)
    echo "   [2/5] Loading Kernel Modules (overlay, br_netfilter)..."
    limactl shell $NODE sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
    limactl shell $NODE sudo modprobe overlay
    limactl shell $NODE sudo modprobe br_netfilter

    echo "   [3/5] Configuring Sysctl (Allowing Pod Communication)..."
    limactl shell $NODE sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
    limactl shell $NODE sudo sysctl --system >/dev/null

    # 3. Install Containerd (The Runtime)
    echo "   [4/5] Installing Containerd..."
    limactl shell $NODE sudo apt-get update >/dev/null
    limactl shell $NODE sudo apt-get install -y containerd >/dev/null
    limactl shell $NODE sudo mkdir -p /etc/containerd
    # Generate default config and force SystemdCgroup = true (Critical for K8s stability)
    limactl shell $NODE sudo containerd config default | limactl shell $NODE sudo tee /etc/containerd/config.toml >/dev/null
    limactl shell $NODE sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    limactl shell $NODE sudo systemctl restart containerd

    # 4. Install Kubeadm, Kubelet, Kubectl
    echo "   [5/5] Installing Kubeadm, Kubelet, Kubectl..."
    limactl shell $NODE sudo apt-get install -y apt-transport-https ca-certificates curl gpg >/dev/null
    
    # Add Kubernetes Repo (Note: Using community repo for pkgs.k8s.io)
    limactl shell $NODE sudo mkdir -p -m 755 /etc/apt/keyrings
    limactl shell $NODE -- sh -c "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg --yes"
    limactl shell $NODE -- sh -c "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list"
    
    limactl shell $NODE sudo apt-get update >/dev/null
    limactl shell $NODE sudo apt-get install -y kubelet kubeadm kubectl >/dev/null
    limactl shell $NODE sudo apt-mark hold kubelet kubeadm kubectl
    
    echo "✅ $NODE Ready!"
done

echo "🎉 All nodes are ready for 'kubeadm init'!"
