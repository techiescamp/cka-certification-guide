#!/bin/bash

set -e

echo "🧨 Deleting 'secureapp-svc' service from 'secure' namespace..."
kubectl delete service secureapp-svc -n secure --ignore-not-found

echo "🧨 Deleting 'secureapp' deployment from 'secure' namespace..."
kubectl delete deployment secureapp -n secure --ignore-not-found

echo "🧨 Deleting TLS secret 'secure-tls' from 'secure' namespace..."
kubectl delete secret secure-tls -n secure --ignore-not-found

echo "🧨 Deleting 'secure' namespace..."
kubectl delete namespace secure --ignore-not-found

echo "✅ Cleanup complete! Helm release, GatewayClass, CRDs, and cloned repo are untouched."
