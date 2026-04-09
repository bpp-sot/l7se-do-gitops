#!/bin/bash
# Reset the lab: remove Argo CD Application resources and any deployed app.
# Useful for re-running exercises from scratch.

echo "Resetting lab state..."

kubectl delete application --all -n argocd --ignore-not-found
kubectl delete namespace gitops-app --ignore-not-found
kubectl create namespace gitops-app

echo ""
echo "Done. All Argo CD Applications removed."
echo "You can re-run the exercises from Exercise 3 onwards."
