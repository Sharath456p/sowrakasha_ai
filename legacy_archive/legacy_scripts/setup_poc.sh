#!/bin/bash
set -e

echo "🚀 Setting up GitLab Agentic POC..."

# Ensure we are using Minikube's Docker daemon
if minikube status | grep -q "Running"; then
    echo "📦 Pointing Docker to Minikube..."
    eval $(minikube docker-env)
else
    echo "⚠️  Minikube is not running. Please start it with 'minikube start' first."
    exit 1
fi

echo "🔨 Building Listener Image..."
docker build -t gitlab-listener:latest ./gitlab_agent_poc/listener

echo "🔨 Building Reviewer Image..."
docker build -t gitlab-reviewer-agent:latest ./gitlab_agent_poc/reviewer

echo "📝 Generatig Secrets (if not exists)..."
if [ ! -f ./gitlab_agent_poc/k8s/02-secrets.yaml ]; then
    echo "⚠️  ./gitlab_agent_poc/k8s/02-secrets.yaml not found."
    echo "    Copying template to 02-secrets.yaml..."
    cp ./gitlab_agent_poc/k8s/02-secrets.yaml.template ./gitlab_agent_poc/k8s/02-secrets.yaml
    echo "❗ PLEASE EDIT ./gitlab_agent_poc/k8s/02-secrets.yaml with your actual credentials before applying!"
else
    echo "✅ 02-secrets.yaml exists."
fi

echo "🚀 Deploying to Kubernetes..."
kubectl apply -f ./gitlab_agent_poc/k8s/01-rbac.yaml

# Check if user wants to apply secrets now or wait
read -p "Do you want to apply the manifests now (make sure secrets are edited)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl apply -f ./gitlab_agent_poc/k8s/02-secrets.yaml
    kubectl apply -f ./gitlab_agent_poc/k8s/03-listener-deployment.yaml
    kubectl apply -f ./gitlab_agent_poc/k8s/04-listener-service.yaml
    
    echo "✅ Deployment applied."
    echo "   Wait for the pod to be ready: kubectl get pods -l app=listener"
    echo "   Forward the port: kubectl port-forward svc/listener-service 8000:80"
else
    echo "Skipping deployment application. Please apply manually when ready."
fi
