#!/bin/bash
set -e

# The NEW Token and Hash from the Re-Init Master
JOIN_CMD="sudo kubeadm join 192.168.5.15:6443 --token xcci62.zwwysnt9yn84ozm2 --discovery-token-ca-cert-hash sha256:470cf4803ae2fce36be8796e0461513d5f6b822a297e988948cc0eb93bc9349a"

echo "🔗 Connecting Workers to the NEW Master..."

# 1. Setup Kubeconfig on Master (Update it for the new cluster)
echo "   [Master] Updating .kube/config..."
limactl shell k8s-master -- sh -c "mkdir -p \$HOME/.kube && sudo cp -f /etc/kubernetes/admin.conf \$HOME/.kube/config && sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"

# 2. Reset and Join Worker 1
echo "   [Worker 1] Resetting & Joining..."
limactl shell k8s-worker-1 sudo kubeadm reset -f >/dev/null
limactl shell k8s-worker-1 -- sh -c "$JOIN_CMD"

# 3. Reset and Join Worker 2
echo "   [Worker 2] Resetting & Joining..."
limactl shell k8s-worker-2 sudo kubeadm reset -f >/dev/null
limactl shell k8s-worker-2 -- sh -c "$JOIN_CMD"

echo "✅ Cluster Recovery Complete! Verifying..."
limactl shell k8s-master kubectl get nodes
