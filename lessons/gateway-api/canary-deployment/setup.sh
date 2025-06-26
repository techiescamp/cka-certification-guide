#!/bin/bash

set -e

echo "🚀 Creating namespace..."
kubectl create ns app-ns || echo "Namespace already exists"

echo "📦 Applying ConfigMaps..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: app1-html
  namespace: app-ns
data:
  index.html: |
    <html>
      <head>
        <style>
          body {
            background-color: #f0f4f8;
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
          }
          .card {
            background-color: #2e7d32; /* Green for App1 */
            color: white;
            padding: 30px 50px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            font-size: 24px;
          }
        </style>
      </head>
      <body>
        <div class="card">Hi, you're connected to <strong>App1</strong></div>
      </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app2-html
  namespace: app-ns
data:
  index.html: |
    <html>
      <head>
        <style>
          body {
            background-color: #f0f4f8;
            font-family: Arial, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
          }
          .card {
            background-color: #1565c0; /* Blue for App2 */
            color: white;
            padding: 30px 50px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            font-size: 24px;
          }
        </style>
      </head>
      <body>
        <div class="card">Hi, you're connected to <strong>App2</strong></div>
      </body>
    </html>
EOF

echo "📦 Deploying applications and services..."
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
  namespace: app-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
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
          name: app1-html
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
  namespace: app-ns
spec:
  selector:
    app: app1
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
  namespace: app-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
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
          name: app2-html
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
  namespace: app-ns
spec:
  selector:
    app: app2
  ports:
  - port: 80
    targetPort: 80
EOF

echo "🌐 Creating Gateway and HTTPRoute..."
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway
  namespace: app-ns
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
  namespace: app-ns
spec:
  parentRefs:
  - name: demo-gateway
  rules:
  - backendRefs:
    - name: app1-service
      port: 80
      weight: 50
    - name: app2-service
      port: 80
      weight: 50
EOF

echo "✅ All resources created successfully!"
