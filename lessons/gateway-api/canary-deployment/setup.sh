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
      <body>
        <h1>Hi, you're connected to <strong>App1</strong></h1>
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
      <body>
        <h1>Hi, you're connected to <strong>App2</strong></h1>
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
  name: app-v1-svc
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
  name: app-v2-svc
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
  name: gateway
  namespace: app-ns
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    hostname: "app.techiescamp.com"
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
  namespace: app-ns
spec:
  parentRefs:
  - name: gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: app-v1-svc
      port: 80
      weight: 50
    - name: app-v2-svc
      port: 80
      weight: 50
EOF

