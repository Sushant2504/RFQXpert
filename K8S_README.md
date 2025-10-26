# RFQXpert Kubernetes Deployment Guide

## 🚀 Overview

This guide will help you deploy RFQXpert to a Kubernetes cluster using Docker Desktop's built-in Kubernetes.

## 📋 Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl installed
- Docker images built locally

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   RAG Service   │    │  Data Service   │
│   (2 replicas)  │    │   (2 replicas)  │    │   (2 replicas)   │
│   Port: 3000    │    │   Port: 8000    │    │   Port: 8001    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ LLM Pipeline    │
                    │ (CronJob)       │
                    │ Every 6 hours   │
                    └─────────────────┘
```

## 📁 Kubernetes Manifests

| File | Description |
|------|-------------|
| `01-namespace.yaml` | Creates rfqxpert namespace |
| `02-configmap-secret.yaml` | Environment variables and secrets |
| `03-persistent-volume.yaml` | Shared storage for data |
| `04-rag-service.yaml` | RAG service deployment and service |
| `05-llm-pipeline.yaml` | LLM pipeline job and cronjob |
| `06-data-service.yaml` | Data service deployment and service |
| `07-frontend.yaml` | Frontend deployment and service |
| `08-ingress.yaml` | Ingress for external access |

## 🚀 Quick Deployment

### 1. Build Docker Images
```bash
# Build all images
docker-compose build

# Or build individually
docker build -f docker/rag-service/Dockerfile -t rfqxpert/rag-service:latest .
docker build -f docker/llm-pipeline/Dockerfile -t rfqxpert/llm-pipeline:latest .
docker build -f docker/data-service/Dockerfile -t rfqxpert/data-service:latest .
docker build -f docker/frontend/Dockerfile -t rfqxpert/frontend:latest .
```

### 2. Deploy to Kubernetes
```bash
# Run the deployment script
./deploy-k8s.sh

# Or deploy manually
kubectl apply -f k8s/
```

### 3. Access the Application
- **Frontend**: http://localhost:30080
- **RAG Service**: http://localhost:30080/api/rag
- **Data Service**: http://localhost:30080/api/data

## 🔧 Manual Deployment Steps

### Step 1: Create Namespace
```bash
kubectl apply -f k8s/01-namespace.yaml
```

### Step 2: Create ConfigMap and Secret
```bash
kubectl apply -f k8s/02-configmap-secret.yaml
```

### Step 3: Create PersistentVolume
```bash
kubectl apply -f k8s/03-persistent-volume.yaml
```

### Step 4: Deploy Services
```bash
kubectl apply -f k8s/04-rag-service.yaml
kubectl apply -f k8s/06-data-service.yaml
kubectl apply -f k8s/07-frontend.yaml
kubectl apply -f k8s/05-llm-pipeline.yaml
```

### Step 5: Deploy Ingress
```bash
kubectl apply -f k8s/08-ingress.yaml
```

## 📊 Monitoring and Management

### Check Service Status
```bash
# View all pods
kubectl get pods -n rfqxpert

# View all services
kubectl get services -n rfqxpert

# View all deployments
kubectl get deployments -n rfqxpert
```

### View Logs
```bash
# RAG Service logs
kubectl logs -f deployment/rag-service -n rfqxpert

# Data Service logs
kubectl logs -f deployment/data-service -n rfqxpert

# Frontend logs
kubectl logs -f deployment/frontend -n rfqxpert

# LLM Pipeline logs
kubectl logs -f job/llm-pipeline-job -n rfqxpert
```

### Port Forwarding
```bash
# Frontend
kubectl port-forward service/frontend 3000:3000 -n rfqxpert

# RAG Service
kubectl port-forward service/rag-service 8000:8000 -n rfqxpert

# Data Service
kubectl port-forward service/data-service 8001:8001 -n rfqxpert
```

### Resource Monitoring
```bash
# View resource usage
kubectl top pods -n rfqxpert

# View node resources
kubectl top nodes
```

## 🔒 Security Configuration

### Update API Key
```bash
# Edit the secret
kubectl edit secret rfqxpert-secrets -n rfqxpert

# Or create a new secret
kubectl create secret generic rfqxpert-secrets \
  --from-literal=GEMINI_API_KEY=your_actual_api_key \
  -n rfqxpert
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: rfqxpert-network-policy
  namespace: rfqxpert
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: rfqxpert
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: rfqxpert
```

## 🔄 Scaling

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: rag-service-hpa
  namespace: rfqxpert
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: rag-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Manual Scaling
```bash
# Scale RAG service
kubectl scale deployment rag-service --replicas=3 -n rfqxpert

# Scale data service
kubectl scale deployment data-service --replicas=3 -n rfqxpert

# Scale frontend
kubectl scale deployment frontend --replicas=3 -n rfqxpert
```

## 🐛 Troubleshooting

### Common Issues

1. **Pods not starting**
   ```bash
   kubectl describe pod <pod-name> -n rfqxpert
   kubectl logs <pod-name> -n rfqxpert
   ```

2. **Images not found**
   ```bash
   # Check if images exist
   docker images | grep rfqxpert
   
   # Build images if missing
   docker-compose build
   ```

3. **Services not accessible**
   ```bash
   # Check service endpoints
   kubectl get endpoints -n rfqxpert
   
   # Test service connectivity
   kubectl exec -it <pod-name> -n rfqxpert -- curl http://rag-service:8000/
   ```

4. **PersistentVolume issues**
   ```bash
   # Check PV status
   kubectl get pv
   kubectl get pvc -n rfqxpert
   
   # Check PV details
   kubectl describe pv rfqxpert-data-pv
   ```

### Debug Commands
```bash
# Get detailed pod information
kubectl describe pod <pod-name> -n rfqxpert

# Check events
kubectl get events -n rfqxpert --sort-by=.metadata.creationTimestamp

# Check resource quotas
kubectl get resourcequota -n rfqxpert

# Check limits
kubectl get limitrange -n rfqxpert
```

## 🧹 Cleanup

### Remove Deployment
```bash
# Delete all resources
kubectl delete namespace rfqxpert

# Or delete individually
kubectl delete -f k8s/
```

### Clean Up Docker Images
```bash
# Remove RFQXpert images
docker rmi rfqxpert/rag-service:latest
docker rmi rfqxpert/llm-pipeline:latest
docker rmi rfqxpert/data-service:latest
docker rmi rfqxpert/frontend:latest
```

## 📈 Production Considerations

### 1. Resource Limits
- Set appropriate CPU and memory limits
- Use resource quotas for namespace
- Monitor resource usage

### 2. Security
- Use proper secrets management
- Implement network policies
- Enable RBAC

### 3. Monitoring
- Set up Prometheus and Grafana
- Configure alerting
- Monitor application metrics

### 4. Backup
- Regular backup of PersistentVolumes
- Backup of configuration
- Disaster recovery plan

## 🎯 Next Steps

1. **Set up monitoring** with Prometheus/Grafana
2. **Implement CI/CD** with GitHub Actions
3. **Add service mesh** with Istio
4. **Set up logging** with ELK stack
5. **Configure backup** strategy

## 📞 Support

If you encounter issues:

1. Check the logs: `kubectl logs -f deployment/<service-name> -n rfqxpert`
2. Verify pod status: `kubectl get pods -n rfqxpert`
3. Check service endpoints: `kubectl get endpoints -n rfqxpert`
4. Review events: `kubectl get events -n rfqxpert`
