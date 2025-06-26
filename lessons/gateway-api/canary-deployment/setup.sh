#!/bin/bash

set -e

echo "🚀 Creating namespace..."
kubectl create ns app-ns || echo "Namespace already exists"

echo "📦 Applying ConfigMaps..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-v1-html
  namespace: app-ns
data:
  index.html: |
    <html>
      <body>
        <h1>Hi, you're connected to App-V1</h1>
      </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-v2-html
  namespace: app-ns
data:
  index.html: |
    <html>
      <body>
        <h1>Hi, you're connected to App-V2</h1>
      </body>
    </html>
EOF

echo "📦 Deploying applications and services..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
  namespace: app-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-v1
  template:
    metadata:
      labels:
        app: app-v1
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: html
        configMap:
          name: app-v1-html
---
apiVersion: v1
kind: Service
metadata:
  name: app-v1-svc
  namespace: app-ns
spec:
  selector:
    app: app-v1
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v2
  namespace: app-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-v2
  template:
    metadata:
      labels:
        app: app-v2
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html/index.html
          subPath: index.html
      volumes:
      - name: html
        configMap:
          name: app-v2-html
---
apiVersion: v1
kind: Service
metadata:
  name: app-v2-svc
  namespace: app-ns
spec:
  selector:
    app: app-v2
  ports:
  - port: 80
    targetPort: 80
EOF

echo "🌐 Creating Gateway and HTTPRoute..."
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: app-gateway
  namespace: app-ns
spec:
  gatewayClassName: nginx-gateway-class
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    hostname: "app.techiescamp.com"
EOF

