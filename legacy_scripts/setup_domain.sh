#!/bin/bash

echo "=========================================="
echo "   Setting up sowrakasha.ai Environment"
echo "=========================================="

# 1. Add Alias to /etc/hosts
DOMAIN="sowrakasha.ai"
IP="127.0.0.1"

if grep -q "$DOMAIN" /etc/hosts; then
    echo "✅  $DOMAIN entry found in /etc/hosts."
else
    echo "🔸  Adding $DOMAIN to /etc/hosts (Password required)..."
    # Create a temporary backup
    sudo cp /etc/hosts /etc/hosts.bak
    echo "$IP $DOMAIN" | sudo tee -a /etc/hosts > /dev/null
    echo "✅  Added $DOMAIN to /etc/hosts."
fi

# 2. Start Port Forwarding on Port 80
echo "🔸  Starting Port Forwarding to Port 80 (Password required)..."
echo "    Opening http://$DOMAIN in your default browser..."
echo "    (Keep this terminal open to maintain the connection)"

# Open browser after a slight delay
(sleep 3 && open "http://$DOMAIN") &

# Start port forward
sudo kubectl port-forward svc/frontend-service 80:80
