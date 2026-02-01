#!/bin/bash
set -e

# The Token and Hash from the Master (Captured from previous step)
JOIN_CMD="sudo kubeadm join 192.168.5.15:6443 --token cc3qdi.zytshk5e738yfwbb --discovery-token-ca-cert-hash sha256:a12f26403d4e0719780a86a8fbbd79dda0fe67a5dfcba1998573d27fbcd38c02"

echo "🔗 Connecting Workers to the Master..."

# 1. Setup Kubeconfig on Master (so we can use kubectl)
echo "   [Master] Setting up .kube/config..."
limactl shell k8s-master -- sh -c "mkdir -p \$HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config && sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"

# 2. Join Worker 1
echo "   [Worker 1] Joining..."
limactl shell k8s-worker-1 -- sh -c "$JOIN_CMD"

# 3. Join Worker 2
echo "   [Worker 2] Joining..."
limactl shell k8s-worker-2 -- sh -c "$JOIN_CMD"

echo "✅ Cluster Join Complete! Verifying..."
limactl shell k8s-master kubectl get nodes
