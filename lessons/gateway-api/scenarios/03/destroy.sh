#!/bin/bash

set -e

echo "🧨 Deleting Ingress 'legacyweb-ingress' from 'default' namespace..."
kubectl delete ingress legacyweb-ingress -n default --ignore-not-found

echo "🧨 Deleting Service 'legacyweb' from 'default' namespace..."
kubectl delete service legacyweb -n default --ignore-not-found

echo "🧨 Deleting Deployment 'legacyweb' from 'default' namespace..."
kubectl delete deployment legacyweb -n default --ignore-not-found

kubectl delete -f gateway.yaml  
kubectl delete -f httproute.yaml

echo "✅ Cleanup complete! Helm release, GatewayClass, CRDs, and repo are untouched."
