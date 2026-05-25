# k8s-probes

# Spring Boot Application

A production-ready Spring Boot application with PostgreSQL and Kubernetes health probes.

## Quick Start

### 1. Build the application

```bash
mvn clean package
```

### 2. Build Docker image

```bash
docker build -t hello-spring:1.0.0 .
```

### 3. Load image to cluster (Kind/Minikube)

```bash
# For Kind
kind load docker-image hello-spring:1.0.0

# For Minikube
minikube image load hello-spring:1.0.0
```

### 4. Deploy to Kubernetes

```bash
# Deploy PostgreSQL first
kubectl apply -f k8s/postgres.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s

# Deploy the application
kubectl apply -f k8s/app.yaml
```

### 5. Access the application

```bash
# Get NodePort URL
kubectl get svc hello-spring-service

# Or port-forward
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
curl http://localhost:30001/actuator/health/liveness
curl http://localhost:30001/actuator/health/readiness

# Test probes in inside pod
kubectl exec -it deployment/hello-spring -- wget -qO- localhost:8080/actuator/health/liveness
kubectl exec -it deployment/hello-spring -- wget -qO- localhost:8080/actuator/health/readiness
```
