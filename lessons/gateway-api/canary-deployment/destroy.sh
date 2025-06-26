#!/bin/bash

set -e

echo "🗑️ Deleting Gateway and HTTPRoute..."
kubectl delete httproute app-route -n app-ns --ignore-not-found
kubectl delete gateway demo-gateway -n app-ns --ignore-not-found

echo "🗑️ Deleting Deployments and Services..."
kubectl delete deployment app1 app2 -n app-ns --ignore-not-found
kubectl delete service app1-service app2-service -n app-ns --ignore-not-found

echo "🗑️ Deleting ConfigMaps..."
kubectl delete configmap app1-html app2-html -n app-ns --ignore-not-found

echo "🗑️ Deleting namespace..."
kubectl delete ns app-ns --ignore-not-found

echo "✅ All resources deleted successfully!"
