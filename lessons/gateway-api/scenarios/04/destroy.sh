#!/bin/bash

set -e

echo "🧨 Deleting HTTPRoute (if applied)..."
kubectl delete -f ~/gateway/httproute.yaml --ignore-not-found

echo "🧨 Deleting backend Deployment and Service..."
kubectl delete deployment backend -n backend-ns --ignore-not-found
kubectl delete service backend-service -n backend-ns --ignore-not-found

echo "🧨 Deleting Gateway..."
kubectl delete gateway web-gateway -n gateway-ns --ignore-not-found

echo "🧨 Deleting ReferenceGrant (if created)..."
kubectl delete referencegrant allow-cross-ns -n backend-ns --ignore-not-found

echo "🧨 Deleting Namespaces..."
kubectl delete ns gateway-ns --ignore-not-found
kubectl delete ns backend-ns --ignore-not-found

echo "🧹 Cleaning up local files..."
rm -f dev-values.yaml
rm -rf ~/gateway

echo "✅ Scenario cleanup complete. Gateway API CRDs and NGINX Gateway Fabric remain installed."
