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

# Step 6: Add entry to /etc/hosts
HOST_ENTRY="172.30.1.2 legacyweb.techiescamp.com"
echo "Adding entry to /etc/hosts..."
if ! grep -q "$HOST_ENTRY" /etc/hosts; then
  echo "$HOST_ENTRY" | sudo tee -a /etc/hosts
  echo "Entry added."
else
  echo "Entry already exists. Skipping..."
fi

echo "✅ Setup complete for legacyweb.techiescamp.com"
