#!/bin/bash

set -e

# Step 1: Delete the Ingress
echo "Deleting Ingress 'legacyweb-ingress'..."
kubectl delete ingress legacyweb-ingress -n default --ignore-not-found

# Step 2: Delete the Service
echo "Deleting Service 'legacyweb'..."
kubectl delete service legacyweb -n default --ignore-not-found

# Step 3: Delete the Deployment
echo "Deleting Deployment 'legacyweb'..."
kubectl delete deployment legacyweb -n default --ignore-not-found

# Step 4: Remove the /etc/hosts entry
HOST_ENTRY="172.30.1.2 legacyweb.techiescamp.com"
echo "Removing host entry from /etc/hosts..."
if grep -q "$HOST_ENTRY" /etc/hosts; then
  sudo sed -i.bak "/$HOST_ENTRY/d" /etc/hosts
  echo "Entry removed."
else
  echo "Entry not found in /etc/hosts. Skipping..."
fi

echo "✅ Cleanup complete. CRDs and NGINX Gateway controller are preserved."
