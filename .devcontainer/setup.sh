#!/bin/bash
set -e

echo "============================================"
echo " L7SE DevOps – GitOps Lab Setup"
echo "============================================"

# Argo CD v2.13.x is pinned deliberately.
# Argo CD v3.x introduced a 'copyutil' init container that crash-loops
# in Docker-in-Docker environments (Minikube inside GitHub Codespaces).
# v2.13 is the latest stable v2 release and does not have this issue.
ARGOCD_VERSION="v2.13.4"

# Install Argo CD CLI
echo ""
echo "[1/4] Installing Argo CD CLI (${ARGOCD_VERSION})..."
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
  --memory=4096 \
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
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo ""
echo "   Waiting for Argo CD pods to be ready (this takes 2-4 minutes)..."

# Wait for repo-server first — it is the most likely to have issues
# and argocd-server depends on it being healthy
kubectl wait --for=condition=available --timeout=300s \
  deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=120s \
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
