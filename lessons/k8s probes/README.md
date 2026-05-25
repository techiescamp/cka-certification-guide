# k8s-probes

## Spring Boot Application

A production-ready Spring Boot application with PostgreSQL and Kubernetes health probes.

## Quick Start

### 1. Build the application

```bash
mvn clean package
```

### 2. Build and push Docker image

```bash
# Build image
docker build -t catninjauser/helloapps-java:3.1.0 .

# Push image so the DigitalOcean cluster can pull it
docker push catninjauser/helloapps-java:3.1.0
```

> If you use a different Docker Hub or registry account, update the image in `manfest/app.yaml` before applying it.

### 3. Connect to DigitalOcean Kubernetes

```bash
# Check that kubectl points to your DigitalOcean cluster
kubectl cluster-info

# Confirm nodes are ready
kubectl get nodes
```

### 4. Deploy to Kubernetes

```bash
# Deploy PostgreSQL first
kubectl apply -f manfest/postgres.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s

# Deploy the application
kubectl apply -f manfest/app.yaml
```

### 5. Access the application

```bash
# Check the NodePort service
kubectl get svc hello-spring-service

# Get DigitalOcean worker node external IP
kubectl get nodes -o wide

# Access using:
# http://<worker-node-external-ip>:32000
```

Or use port-forward:

```bash
kubectl port-forward svc/hello-spring-service 8080:80
```

Open http://localhost:8080

## Health Probe Behavior

| Probe | Endpoint | Checks | On Failure |
|-------|----------|--------|------------|
| Startup | `/actuator/health/liveness` | App responding | Wait (up to 5 min) |
| Liveness | `/actuator/health/liveness` | App alive | RESTART container |
| Readiness | `/actuator/health/readiness` | DB connected | Remove from Service |

## Without Database

The app will:
- ✅ Start successfully
- ✅ Stay running (liveness passes)
- ❌ Not receive traffic (readiness fails)
- ✅ Auto-recover when DB available

## Check Connection Logs

```bash
kubectl exec -it postgres-0 -- psql -U postgres -d hellodb -c "SELECT * FROM connection_log;"
```

## Useful Commands

```bash
# Check pod status
kubectl get pods -w

# Check endpoints (ready pods)
kubectl get endpoints hello-spring-service

# View app logs
kubectl logs -f deployment/hello-spring

# Test probes manually from outside pod
curl http://<worker-node-external-ip>:32000/actuator/health/liveness
curl http://<worker-node-external-ip>:32000/actuator/health/readiness

# Or, if using port-forward
curl http://localhost:8080/actuator/health/liveness
curl http://localhost:8080/actuator/health/readiness

# Test probes inside pod
kubectl exec -it deployment/hello-spring -- wget -qO- localhost:8080/actuator/health/liveness
kubectl exec -it deployment/hello-spring -- wget -qO- localhost:8080/actuator/health/readiness
```
