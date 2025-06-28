#!/bin/bash

set -e

# Step 1: Install Gateway API CRDs if not present
echo "🔍 Checking if Gateway API CRDs are already installed..."
if ! kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null; then
  echo "📦 Installing Gateway API CRDs..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
else
  echo "✅ Gateway API CRDs already installed. Skipping Step 1."
fi

# Step 2: Clone repo if not already present
echo "🔍 Checking if CKA repo already exists..."
if [ ! -d "cka-certification-guide" ]; then
  echo "📥 Cloning the CKA certification guide repository..."
  git clone https://github.com/techiescamp/cka-certification-guide.git
else
  echo "✅ Repository already cloned. Skipping Step 2."
fi

cd cka-certification-guide/helm-charts/nginx-gateway-fabric/

# Install Helm chart
echo "🚀 Installing NGINX Gateway Fabric via Helm..."
helm install ngf . -n nginx-gateway --create-namespace || echo "⚠️ Helm release already exists. Skipping."

# Create GatewayClass
echo "📄 Creating GatewayClass resource..."
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-gateway-class
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
  parametersRef:
    group: gateway.nginx.org
    kind: NginxProxy
    name: ngf-proxy-config
    namespace: nginx-gateway
EOF

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
  gatewayClassName: nginx-gateway-class
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
