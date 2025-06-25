#!/bin/bash

set -e

# Step 1: Install Gateway API CRDs if not already present
echo "✅ Checking for Gateway API CRDs..."
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  echo "📦 Installing Gateway API CRDs..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
else
  echo "✅ Gateway API CRDs already installed. Skipping..."
fi

# Step 2: Install NGINX Gateway Fabric if not already installed
echo "✅ Checking for NGINX Gateway Fabric release..."
if ! helm list -n nginx-gateway | grep -q "^ngf"; then
  echo "📦 Installing NGINX Gateway Fabric..."

  cat <<EOF > dev-values.yaml
service:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      name: http
      nodePort: 32000
    - port: 443
      targetPort: 443
      protocol: TCP
      name: https
      nodePort: 32443
EOF

  helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
    --create-namespace -n nginx-gateway -f dev-values.yaml
else
  echo "✅ NGINX Gateway Fabric already installed. Skipping..."
fi

# Step 3: Create 'prod' namespace if it doesn't exist
echo "🔧 Creating 'prod' namespace..."
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Create NGINX deployment in 'prod'
echo "🚀 Creating NGINX deployment 'web-app' in 'prod' namespace..."
kubectl apply -n prod -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

# Step 5: Expose the deployment as a ClusterIP service
echo "🌐 Creating ClusterIP service 'web-app-svc'..."
kubectl apply -n prod -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-app-svc
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# Step 6: Add host entry to /etc/hosts
echo "📝 Adding entry to /etc/hosts..."
HOST_ENTRY="172.30.1.2 prod.techiescamp.com"
if ! grep -q "$HOST_ENTRY" /etc/hosts; then
  echo "$HOST_ENTRY" | sudo tee -a /etc/hosts > /dev/null
  echo "✅ Entry added to /etc/hosts."
else
  echo "✅ Entry already exists in /etc/hosts. Skipping..."
fi

echo "🎉 All tasks completed."
