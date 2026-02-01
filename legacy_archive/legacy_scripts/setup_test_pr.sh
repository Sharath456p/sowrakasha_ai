#!/bin/bash
set -e

# Configuration
REPO_URL="https://gitlab.com/sharath-poc/test-mr-project.git"
TOKEN="glpat-UIaLgqaOlenZqjvRpwHA5m86MQp1OmptMDJ4Cw.01.1203618k1"

# Construct Auth URL
AUTH_REPO_URL=${REPO_URL/https:\/\//https:\/\/oauth2:${TOKEN}@}

TEMP_DIR="temp_repo_setup"

echo "🧹 Cleaning up..."
rm -rf $TEMP_DIR

echo "⬇️  Cloning repository..."
git clone $AUTH_REPO_URL $TEMP_DIR
cd $TEMP_DIR

# 1. Setup Main Branch
echo "🌱 Setting up main branch..."
cat <<EOF > calculator.py
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b
EOF

if [ ! -f README.md ]; then
    echo "# Test Project" > README.md
fi

git add .
git commit -m "Initial commit" || echo "Nothing to commit"
git push origin main || git push origin master

# 2. Create Feature Branch with Bugs
echo "🐛 creating feature branch with bugs..."
git checkout -b feature/bad-code

cat <<EOF > calculator.py
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def divide(a, b):
    # Bug: No check for division by zero
    return a / b

# Security Issue: Using eval is dangerous
def unsafe_math(expression):
    print("Calculating...")
    return eval(expression)
EOF

git add calculator.py
git commit -m "Add divide and unsafe math functions"
git push origin feature/bad-code

echo ""
echo "✅ Test content pushed!"
echo "👉 Go to: https://gitlab.com/sharath-poc/test-mr-project/-/merge_requests/new"
echo "   and create a Mere Request from 'feature/bad-code' into 'main'."
