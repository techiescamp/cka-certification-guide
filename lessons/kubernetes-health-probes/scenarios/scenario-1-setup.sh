#!/usr/bin/env bash
# Sets up the environment for a probes scenario.
set -euo pipefail

NS="probe-config"

echo "Creating namespace $NS..."
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f - >/dev/null

echo "Deploying PostgreSQL..."
kubectl apply -n "$NS" -f https://raw.githubusercontent.com/techiescamp/cka-certification-guide/main/lessons/kubernetes-health-probes/k8s-manifest/postgres.yaml >/dev/null
kubectl rollout status statefulset/postgres -n "$NS" --timeout=180s >/dev/null

echo "Deploying the Orders API..."
kubectl apply -n "$NS" -f - >/dev/null <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: orders-api-config
data:
  DB_URL: "jdbc:postgresql://postgres-service:5432/ordersdb"
  DB_USERNAME: "postgres"
---
apiVersion: v1
kind: Service
metadata:
  name: orders-api-service
spec:
  selector:
    app: orders-api
  ports:
    - port: 80
      targetPort: 8080
      name: http
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-api
  labels:
    app: orders-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: orders-api
  template:
    metadata:
      labels:
        app: orders-api
    spec:
      containers:
        - name: orders-api
          image: devopscube/orders-api:1.0.0
          ports:
            - containerPort: 8080
              name: http
          env:
            - name: DB_URL
              valueFrom:
                configMapKeyRef:
                  name: orders-api-config
                  key: DB_URL
            - name: DB_USERNAME
              valueFrom:
                configMapKeyRef:
                  name: orders-api-config
                  key: DB_USERNAME
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: POSTGRES_PASSWORD
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
YAML

echo
echo "Done. The Orders API is running in the probe-config namespace, without any probes."
