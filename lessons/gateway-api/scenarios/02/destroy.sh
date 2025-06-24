#!/bin/bash

set -e

# Step 1: Delete the 'secure' namespace (includes all resources inside)
echo "Deleting 'secure' namespace and all its resources..."
kubectl delete namespace secure --ignore-not-found

# Step 2: Remove the hosts entry for secureapp.techiescamp.com
HOST_ENTRY="172.30.1.2 secureapp.techiescamp.com"
echo "Removing host entry from /etc/hosts..."
if grep -q "$HOST_ENTRY" /etc/hosts; then
  sudo sed -i.bak "/$HOST_ENTRY/d" /etc/hosts
  echo "Entry removed."
else
  echo "Entry not found in /etc/hosts. Skipping..."
fi

echo "✅ Cleanup complete. Gateway API CRDs and controller are preserved."
