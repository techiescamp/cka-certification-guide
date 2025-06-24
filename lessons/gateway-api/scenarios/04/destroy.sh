#!/bin/bash

set -e

# Step 1: Delete HTTPRoute
echo "Deleting HTTPRoute 'frontend-route'..."
kubectl delete httproute frontend-route -n frontend --ignore-not-found

# Step 2: Delete Gateway
echo "Deleting Gateway 'frontend-gateway'..."
kubectl delete gateway frontend-gateway -n frontend --ignore-not-found

# Step 3: Delete frontendapp Deployment and Service
echo "Deleting frontendapp deployment and service..."
kubectl delete deployment frontendapp -n frontend --ignore-not-found
kubectl delete service frontendapp-svc -n frontend --ignore-not-found

# Step 4: Delete backendapp Deployment and Service
echo "Deleting backendapp deployment and service..."
kubectl delete deployment backendapp -n backend --ignore-not-found
kubectl delete service backendapp-svc -n backend --ignore-not-found

# Step 5: Delete frontend and backend namespaces
echo "Deleting namespaces 'frontend' and 'backend'..."
kubectl delete namespace frontend --ignore-not-found
kubectl delete namespace backend --ignore-not-found

# Step 6: Remove /etc/hosts entries
echo "Removing /etc/hosts entries..."
for host in frontend.techiescamp.com backend.techiescamp.com; do
  HOST_ENTRY="172.30.1.2 $host"
  if grep -q "$HOST_ENTRY" /etc/hosts; then
    sudo sed -i.bak "/$HOST_ENTRY/d" /etc/hosts
    echo "Removed: $HOST_ENTRY"
  else
    echo "Not found in /etc/hosts: $HOST_ENTRY"
  fi
done

echo "✅ Cleanup complete. CRDs and Gateway controller are preserved."
