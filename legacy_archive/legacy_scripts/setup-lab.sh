#!/bin/bash
set -e

echo "🚀 Starting On-Prem Lab Provisioning..."

# 1. Check if instances exist and delete if they do (Fresh Start)
for node in k8s-master k8s-worker-1 k8s-worker-2; do
    if multipass info $node &>/dev/null; then
        echo "⚠️  Found existing $node. Deleting..."
        multipass delete $node
        multipass purge
    fi
done

# 2. Launch Master Node (2GB RAM, 2 CPUs)
echo "📦 Launching Master Node..."
multipass launch --name k8s-master --cpus 2 --memory 2G --disk 10G lts

# 3. Launch Worker Nodes (1GB RAM, 1 CPU each)
echo "📦 Launching Worker Node 1..."
multipass launch --name k8s-worker-1 --cpus 1 --memory 1G --disk 10G lts

echo "📦 Launching Worker Node 2..."
multipass launch --name k8s-worker-2 --cpus 1 --memory 1G --disk 10G lts

echo "✅ Lab Provisioning Complete!"
multipass list
