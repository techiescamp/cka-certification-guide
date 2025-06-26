#!/bin/bash

set -e

echo "🗑️ Deleting Gateway and HTTPRoute..."
kubectl delete httproute app-route -n weighted-routing-demo --ignore-not-found
kubectl delete gateway demo-gateway -n weighted-routing-demo --ignore-not-found

echo "🗑️ Deleting Deployments and Services..."
kubectl delete deployment app1 app2 -n weighted-routing-demo --ignore-not-found
kubectl delete service app1-service app2-service -n weighted-routing-demo --ignore-not-found

echo "🗑️ Deleting ConfigMaps..."
kubectl delete configmap app1-html app2-html -n weighted-routing-demo --ignore-not-found

echo "🗑️ Deleting namespace..."
kubectl delete ns weighted-routing-demo --ignore-not-found

echo "✅ All resources deleted successfully!"
