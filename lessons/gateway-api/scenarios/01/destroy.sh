#!/bin/bash

set -e

# Step 1: Delete the 'prod' namespace (includes all resources inside)
echo "Deleting 'prod' namespace..."
kubectl delete namespace prod --ignore-not-found

# Step 2: Remove the line from /etc/hosts
HOST_ENTRY="172.30.1.2 prod.techiescamp.com"
echo "Removing host entry from /etc/hosts..."
sudo sed -i.bak "/$HOST_ENTRY/d" /etc/hosts && echo "Entry removed." || echo "Entry not found."

echo "Cleanup complete. CRDs and NGINX Gateway Fabric remain untouched."
