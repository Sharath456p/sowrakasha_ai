#!/bin/bash
set -e

echo "🚀 Starting On-Prem Lab Provisioning (Lima Edition)..."

# 1. Define the config for a generic Ubuntu node
# We use a custom YAML to define resources
cat <<EOF > k8s-node.yaml
images:
- location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  arch: "x86_64"
- location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-arm64.img"
  arch: "aarch64"
cpus: 2
memory: "2GiB"
disk: "20GiB"
ssh:
  localPort: 0
  loadDotSSHPubKeys: true
EOF

# 2. Check and launch Master
if limactl list | grep -q "k8s-master"; then
    echo "⚠️  k8s-master already exists"
else
    echo "📦 Launching Master Node (k8s-master)..."
    # --tty=false prevents it from entering the shell immediately
    limactl start --name=k8s-master --tty=false ./k8s-node.yaml
fi

# 3. Check and launch Workers (Using sed to lower RAM for workers to 1GB to save resources)
# Critical for 8GB Mac: Workers only get 1GB each
sed 's/memory: "2GiB"/memory: "1GiB"/g' k8s-node.yaml > k8s-worker.yaml
sed -i '' 's/cpus: 2/cpus: 1/g' k8s-worker.yaml

for i in 1 2; do
    if limactl list | grep -q "k8s-worker-$i"; then
        echo "⚠️  k8s-worker-$i already exists"
    else
        echo "📦 Launching Worker Node $i (k8s-worker-$i)..."
        limactl start --name=k8s-worker-$i --tty=false ./k8s-worker.yaml
    fi
done

echo "✅ Lima VM Provisioning Complete!"
limactl list
