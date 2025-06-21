#!/bin/bash

set -e

# Step 1: Check and apply Gateway API CRDs
echo "Checking for Gateway API CRDs..."
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  echo "Installing Gateway API CRDs..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
else
  echo "Gateway API CRDs already installed. Skipping..."
fi

# Step 2: Check and install NGINX Gateway Fabric controller
echo "Checking for NGINX Gateway Fabric release..."
if ! helm list -n nginx-gateway | grep -q "^ngf"; then
  echo "Installing NGINX Gateway Fabric..."
  helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway
else
  echo "NGINX Gateway Fabric already installed. Skipping..."
fi

# Step 3: Create 'secure' namespace
echo "Creating 'secure' namespace..."
kubectl create namespace secure --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Create Deployment in 'secure' namespace
echo "Creating NGINX Deployment 'secureapp'..."
kubectl apply -n secure -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secureapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secureapp
  template:
    metadata:
      labels:
        app: secureapp
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

# Step 5: Create Service
echo "Creating Service 'secureapp-svc'..."
kubectl apply -n secure -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: secureapp-svc
spec:
  selector:
    app: secureapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# Step 6: Generate TLS cert and key
echo "Generating TLS certificate and key for secureapp.techiescamp.com..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=secureapp.techiescamp.com/O=secureapp" \
  -keyout tls.key -out tls.crt

# Step 7: Create TLS secret
echo "Creating TLS secret 'secure-tls'..."
kubectl create secret tls secure-tls \
  --cert=tls.crt --key=tls.key -n secure

# Cleanup local files
rm tls.crt tls.key

# Step 8: Add /etc/hosts entry
HOST_ENTRY="172.30.1.2 secureapp.techiescamp.com"
echo "Adding entry to /etc/hosts..."
if ! grep -q "$HOST_ENTRY" /etc/hosts; then
  echo "$HOST_ENTRY" | sudo tee -a /etc/hosts
  echo "Entry added."
else
  echo "Entry already exists. Skipping..."
fi

echo "✅ Setup complete."
