#!/bin/bash
# Retrieve the initial admin password for Argo CD.
# Username is always: admin

echo "============================================"
echo " Argo CD Initial Admin Credentials"
echo "============================================"
echo ""
echo "Username: admin"
echo -n "Password: "
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "Log in via the CLI:"
echo "  argocd login localhost:8080 --insecure --username admin \\"
echo "    --password \$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
echo ""
echo "NOTE: Change this password in production."
echo "============================================"
