#!/bin/bash

# Configuration
PROJECT_DIR="telegram_demo"
VENV_DIR=".venv"

echo "=== Telegram MitM Simulator (MOCK MODE) ==="
echo "[*] Telegram's defenses blocked the live connection (Recaptcha)."
echo "[*] Switching to Mock Mode to demonstrate the Phishing Workflow."

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
fi

source $VENV_DIR/bin/activate

# Dummy credentials for mock mode
export API_ID="123456"
export API_HASH="mock_hash_value"
export MOCK_MODE="true"

echo ""
echo "=== ATTACKER SERVER STARTED (MOCK) ==="
echo "Phishing Page available at: http://localhost:5000"
echo "Switch to your browser and enter ANY phone number."
echo "==============================="
echo ""

python $PROJECT_DIR/server.py
