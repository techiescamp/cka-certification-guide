#!/bin/bash

set -e

# Step 1: Install Gateway API CRDs if not already installed
echo "Checking for Gateway API CRDs..."
if ! kubectl get crd gateways.gateway.networking.k8s.io &>/dev/null; then
  echo "Installing Gateway API CRDs..."
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
else
  echo "Gateway API CRDs already installed. Skipping..."
fi

# Step 2: Install NGINX Gateway Fabric if not already installed
echo "Checking for NGINX Gateway Fabric..."
if ! helm list -n nginx-gateway | grep -q "^ngf"; then
  echo "Installing NGINX Gateway Fabric..."
  helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway
else
  echo "NGINX Gateway Fabric already installed. Skipping..."
fi

# Step 3: Create backend namespace
echo "Creating namespace 'backend'..."
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -

# Step 4: Deploy backendapp in backend namespace
echo "Creating backendapp deployment..."
kubectl apply -n backend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backendapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backendapp
  template:
    metadata:
      labels:
        app: backendapp
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

# Step 5: Create backendapp-svc
echo "Creating backendapp-svc..."
kubectl apply -n backend -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: backendapp-svc
spec:
  selector:
    app: backendapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

# Step 6: Create frontend namespace
echo "Creating namespace 'frontend'..."
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -

# Step 7: Create frontendapp deployment
echo "Creating frontendapp deployment..."
kubectl apply -n frontend -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontendapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontendapp
  template:
    metadata:
      labels:
        app: frontendapp
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
EOF

# Step 8: Create frontendapp-svc
echo "Creating frontendapp-svc..."
kubectl apply -n frontend -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: frontendapp-svc
spec:
  selector:
    app: frontendapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

# Step 9: Create Gateway in frontend (using existing GatewayClass 'nginx')
echo "Creating Gateway 'frontend-gateway' in 'frontend' namespace..."
kubectl apply -n frontend -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: frontend-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: "frontend.techiescamp.com"
    allowedRoutes:
      namespaces:
        from: All
EOF

# Step 10: Create HTTPRoute for frontend
echo "Creating HTTPRoute 'frontend-route'..."
kubectl apply -n frontend -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: frontend-route
spec:
  parentRefs:
  - name: frontend-gateway
  hostnames:
  - "frontend.techiescamp.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontendapp-svc
      port: 80
EOF

# Step 11: Add /etc/hosts entries
echo "Adding entries to /etc/hosts..."
for host in frontend.techiescamp.com backend.techiescamp.com; do
  HOST_ENTRY="172.30.1.2 $host"
  if ! grep -q "$HOST_ENTRY" /etc/hosts; then
    echo "$HOST_ENTRY" | sudo tee -a /etc/hosts
    echo "Entry added: $HOST_ENTRY"
  else
    echo "Entry already exists: $HOST_ENTRY"
  fi
done

echo "✅ Setup complete: frontend and backend apps are deployed. Gateway configured only for frontend."
