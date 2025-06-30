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
helm install ngf . -n nginx-gateway --create-namespace -f custom-values.yaml || echo "⚠️ Helm release already exists. Skipping."

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

