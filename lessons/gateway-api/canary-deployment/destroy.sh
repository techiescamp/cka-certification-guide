#!/bin/bash

set -e

echo "🧨 Deleting Gateway and HTTPRoute..."
kubectl delete httproute app-route -n app-ns --ignore-not-found
kubectl delete gateway app-gateway -n app-ns --ignore-not-found

echo "🧨 Deleting Deployments and Services..."
kubectl delete deployment app-v1 -n app-ns --ignore-not-found
kubectl delete deployment app-v2 -n app-ns --ignore-not-found
kubectl delete service app-v1-svc -n app-ns --ignore-not-found
kubectl delete service app-v2-svc -n app-ns --ignore-not-found

echo "🧨 Deleting ConfigMaps..."
kubectl delete configmap app1-html -n app-ns --ignore-not-found
kubectl delete configmap app2-html -n app-ns --ignore-not-found

echo "🧨 Deleting Namespace..."
kubectl delete namespace app-ns --ignore-not-found

echo "✅ Cleanup completed!"
