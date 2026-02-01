#!/bin/bash

# Configuration
PROJECT_DIR="telegram_demo"
VENV_DIR=".venv"

echo "=== Telegram MitM Simulator Setup ==="

# 1. Check/Install Python Dependencies
if [ ! -d "$VENV_DIR" ]; then
    echo "[*] Creating virtual environment..."
    python3 -m venv $VENV_DIR
fi

source $VENV_DIR/bin/activate

echo "[*] Installing dependencies..."
pip install -r $PROJECT_DIR/requirements.txt > /dev/null

# 2. Ask for Credentials
echo ""
echo "To run this simulator, you need your Telegram API credentials."
echo "Get them from https://my.telegram.org -> API Development Tools."
echo ""

read -p "Enter API ID: " API_ID
read -p "Enter API HASH: " API_HASH

if [ -z "$API_ID" ] || [ -z "$API_HASH" ]; then
    echo "Error: Credentials cannot be empty."
    exit 1
fi

export API_ID=$API_ID
export API_HASH=$API_HASH

# 3. Start Server
echo ""
echo "=== ATTACKER SERVER STARTED ==="
echo "Phishing Page available at: http://localhost:5000"
echo "Switch to your browser and enter your phone number."
echo "Watch this terminal for 'Stolen Session' logs."
echo "==============================="
echo ""

python $PROJECT_DIR/server.py
