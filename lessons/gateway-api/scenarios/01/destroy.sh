#!/bin/bash

set -e

echo "🧨 Deleting 'web-app-svc' service from 'prod' namespace..."
kubectl delete service web-app-svc -n prod --ignore-not-found

echo "🧨 Deleting 'web-app' deployment from 'prod' namespace..."
kubectl delete deployment web-app -n prod --ignore-not-found

echo "🧨 Deleting 'prod' namespace..."
kubectl delete namespace prod --ignore-not-found

echo "✅ Cleanup complete! GatewayClass, Helm release, and CRDs are untouched."
