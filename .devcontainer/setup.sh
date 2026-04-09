#!/bin/bash
set -e

echo "============================================"
echo " L7SE DevOps – GitOps Lab Setup"
echo "============================================"

# Install Argo CD CLI
echo ""
echo "[1/4] Installing Argo CD CLI..."
ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -sSL -o /usr/local/bin/argocd \
  "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
chmod +x /usr/local/bin/argocd
echo "   Argo CD CLI installed: $(argocd version --client --short 2>/dev/null || echo 'installed')"

# Start Minikube
echo ""
echo "[2/4] Starting Minikube (this takes 2-3 minutes)..."
minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=3072 \
  --kubernetes-version=stable \
  --wait=all \
  --no-vtx-check
echo "   Minikube started successfully"

# Enable Minikube addons
echo ""
echo "[3/4] Enabling Minikube addons..."
minikube addons enable metrics-server
echo "   metrics-server enabled"

# Install Argo CD onto the cluster
echo ""
echo "[4/4] Installing Argo CD onto the cluster..."
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo "   Waiting for Argo CD pods to be ready (this takes 2-4 minutes)..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-server -n argocd
echo "   Argo CD is ready"

# Patch argocd-server to use --insecure so HTTP works over port-forward
kubectl patch deployment argocd-server -n argocd \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'

# Wait for the patched rollout
kubectl rollout status deployment/argocd-server -n argocd --timeout=120s

echo ""
echo "============================================"
echo " Setup complete!"
echo ""
echo " Next steps:"
echo "   1. Run: bash scripts/start-argocd-ui.sh"
echo "      to expose the Argo CD dashboard"
echo ""
echo "   2. Get the initial admin password:"
echo "      bash scripts/get-argocd-password.sh"
echo ""
echo "   3. Open the PORTS tab and click the"
echo "      globe icon next to port 8080"
echo "============================================"
