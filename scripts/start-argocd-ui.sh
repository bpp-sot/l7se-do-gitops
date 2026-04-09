#!/bin/bash
# Expose the Argo CD server UI via port-forward on port 8080.
# In GitHub Codespaces, the PORTS tab will automatically detect
# this and give you a forwarded URL.

echo "Starting Argo CD UI port-forward on port 8080..."
echo "Open the PORTS tab → click the globe icon next to port 8080."
echo ""
echo "Press Ctrl+C to stop."
echo ""

kubectl port-forward svc/argocd-server -n argocd 8080:80
