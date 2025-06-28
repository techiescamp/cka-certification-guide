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

# Step 3: Create 'prod' namespace
echo "🔧 Creating 'prod' namespace..."
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Create nginx Deployment in 'prod'
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

# Step 5: Expose nginx via ClusterIP service
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

echo "✅ Setup complete! You can now route traffic to the web-app-svc in 'prod' namespace."
