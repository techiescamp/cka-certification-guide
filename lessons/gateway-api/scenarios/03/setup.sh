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

# Step 3: Deploy NGINX app in default namespace
echo "Deploying NGINX Deployment 'legacyweb' in 'default' namespace..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacyweb
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: legacyweb
  template:
    metadata:
      labels:
        app: legacyweb
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

# Step 4: Create ClusterIP service
echo "Creating ClusterIP Service 'legacyweb'..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: legacyweb
  namespace: default
spec:
  selector:
    app: legacyweb
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
EOF

# Step 5: Create Ingress object (named legacyweb-ingress)
echo "Creating Ingress 'legacyweb-ingress'..."
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: legacyweb-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: legacyweb.techiescamp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: legacyweb
            port:
              number: 80
EOF

