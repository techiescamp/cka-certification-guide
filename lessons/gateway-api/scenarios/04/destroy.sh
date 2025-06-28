#!/bin/bash

set -e

echo "🧨 Deleting HTTPRoute 'web-route' from 'gateway-ns'..."
kubectl delete -f ~/gateway/httproute.yaml --ignore-not-found

echo "🧨 Deleting NGINX backend deployment and service from 'backend-ns'..."
kubectl delete deployment backend -n backend-ns --ignore-not-found
kubectl delete service backend-service -n backend-ns --ignore-not-found

echo "🧨 Deleting namespaces 'gateway-ns' and 'backend-ns'..."
kubectl delete namespace gateway-ns --ignore-not-found
kubectl delete namespace backend-ns --ignore-not-found

echo "🧹 Cleaning up local 'httproute.yaml' file..."
rm -f ~/gateway/httproute.yaml
rmdir --ignore-fail-on-non-empty ~/gateway || true

echo "✅ Cleanup complete! CRDs, repo, Helm release, and GatewayClass are untouched."
