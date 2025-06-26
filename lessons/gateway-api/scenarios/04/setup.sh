#!/bin/bash

set -e

echo "🔍 Step 1: Checking for Gateway API CRDs..."
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  echo "📦 Installing Gateway API CRDs..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
else
  echo "✅ Gateway API CRDs already installed. Skipping..."
fi

echo "🔍 Step 2: Checking for NGINX Gateway Fabric release..."
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

echo "📁 Step 3: Creating namespaces..."
kubectl create ns gateway-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns backend-ns --dry-run=client -o yaml | kubectl apply -f -

echo "🛠 Step 4: Creating Gateway in 'gateway-ns'..."
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: gateway-ns
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
EOF

echo "📝 Step 5: Creating placeholder HTTPRoute..."
mkdir -p ~/gateway

cat <<EOF > ~/gateway/httproute.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: gateway-ns
spec:
  parentRefs:
    - name: web-gateway
  rules:
    - backendRefs:
        # TODO: Add backendRef to point to backend-service in backend-ns
        # Example:
        # - name: 
        #   namespace: 
        #   port: 
EOF

echo "🚀 Step 6: Deploying NGINX backend in 'backend-ns'..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend-ns
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

kubectl apply -f ~/gateway/httproute.yaml
