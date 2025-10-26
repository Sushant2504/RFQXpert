# RFQXpert - Complete DevOps Implementation Guide

## 🎯 Overview

This guide provides comprehensive deployment strategies for RFQXpert across multiple platforms:
- **Local Development**: Docker Compose
- **Production**: Kubernetes (K8s)
- **Cloud**: AWS EC2
- **CI/CD**: GitHub Actions (conceptual)

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Local Docker Deployment](#local-docker-deployment)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [AWS Cloud Deployment](#aws-cloud-deployment)
6. [CI/CD Pipeline](#cicd-pipeline)
7. [Monitoring & Logging](#monitoring--logging)
8. [Security Best Practices](#security-best-practices)
9. [Backup & Disaster Recovery](#backup--disaster-recovery)
10. [Troubleshooting](#troubleshooting)

---

## 🏗️ Architecture Overview

RFQXpert consists of 4 main microservices:

```
┌─────────────────────────────────────────────────────────────┐
│                      RFQXpert Architecture                   │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Frontend   │    │ RAG Service  │    │Data Service  │
│  (Next.js)   │◄───┤  (FastAPI)   │◄───┤  (FastAPI)   │
│   Port 3000  │    │   Port 8000  │    │  Port 8001   │
└──────────────┘    └──────────────┘    └──────────────┘
       │                   │                   │
       └───────────────────┴───────────────────┘
                           │
                  ┌──────────────┐
                  │ LLM Pipeline │
                  │  (CronJob)   │
                  │ Every 6 hrs  │
                  └──────────────┘
```

### Components

| Component | Technology | Purpose | Port |
|-----------|-----------|---------|------|
| **Frontend** | Next.js | User interface | 3000 |
| **RAG Service** | FastAPI + Python | Document processing & embeddings | 8000 |
| **Data Service** | FastAPI + Python | Results serving API | 8001 |
| **LLM Pipeline** | Python | ML agents for analysis | - |

---

## 📋 Prerequisites

### Common Requirements
- **Operating System**: Linux, macOS, or Windows (WSL2)
- **Git**: Version control
- **API Key**: Google Gemini API key

### For Docker Deployment
- Docker Desktop 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum
- 10GB free disk space

### For Kubernetes Deployment
- Kubernetes cluster (Docker Desktop, minikube, or cloud)
- kubectl 1.20+
- 8GB RAM recommended
- 20GB free disk space

### For AWS Deployment
- AWS Account
- EC2 t2.micro instance (Free Tier)
- Security Group configuration
- SSH access

---

## 🐳 Local Docker Deployment

### Quick Start

```bash
# 1. Clone the repository
git clone <repository-url>
cd RFQXpert

# 2. Create environment file
echo "GEMINI_API_KEY=your_api_key_here" > .env

# 3. Build and start services
docker-compose up -d

# 4. Access the application
# Frontend: http://localhost:3000
# RAG Service: http://localhost:8000
# Data Service: http://localhost:8001
```

### Detailed Setup

#### 1. Environment Configuration

Create a `.env` file:

```bash
# API Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Optional: Override defaults
PYTHONPATH=/app
DATA_DIR=/app/data
RAG_DATA_DIR=/app/RAG/data
NODE_ENV=production
PORT=3000
```

#### 2. Build Docker Images

```bash
# Build all services
docker-compose build

# Build specific service
docker-compose build rag-service
docker-compose build llm-pipeline
docker-compose build data-service
docker-compose build frontend
```

#### 3. Start Services

```bash
# Start all services in background
docker-compose up -d

# Start with ML pipeline
docker-compose --profile pipeline up -d

# Start specific service
docker-compose up -d rag-service
```

#### 4. View Logs

```bash
# All logs
docker-compose logs -f

# Specific service
docker-compose logs -f rag-service
docker-compose logs -f llm-pipeline
docker-compose logs -f data-service
docker-compose logs -f frontend
```

#### 5. Service Management

```bash
# Check status
docker-compose ps

# Restart service
docker-compose restart rag-service

# Stop services
docker-compose stop

# Stop and remove volumes
docker-compose down -v

# Rebuild everything
docker-compose build --no-cache
docker-compose up -d
```

### Production Configuration

Use production override file:

```bash
# Start with production settings
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Production features:
- Resource limits (CPU/Memory)
- Health checks
- Log rotation
- Restart policies
- Enhanced logging

### Directory Structure

```
RFQXpert/
├── docker/
│   ├── rag-service/
│   │   └── Dockerfile
│   ├── llm-pipeline/
│   │   └── Dockerfile
│   ├── data-service/
│   │   └── Dockerfile
│   └── frontend/
│       └── Dockerfile
├── docker-compose.yml          # Base configuration
├── docker-compose.prod.yml     # Production overrides
├── docker-setup.sh             # Setup script
├── data/                       # Data volume
└── .env                        # Environment variables
```

### Service Dependencies

1. **RAG Service** → Creates `rag_ready.flag`
2. **LLM Pipeline** → Waits for flag, runs periodically
3. **Data Service** → Serves processed results
4. **Frontend** → Provides UI

### Health Checks

All services include health checks:

```bash
# RAG Service
curl http://localhost:8000/

# Data Service  
curl http://localhost:8001/data

# Frontend
curl http://localhost:3000/
```

---

## ☸️ Kubernetes Deployment

### Quick Start

```bash
# 1. Ensure Docker Desktop K8s is running
kubectl cluster-info

# 2. Build Docker images
docker-compose build

# 3. Deploy to Kubernetes
./deploy-k8s.sh

# 4. Access application
# Frontend: http://localhost:30080
```

### Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Kubernetes Cluster                   │
│                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Frontend   │  │ RAG Service │  │Data Service │ │
│  │   (2 pods)  │  │   (2 pods)  │  │  (2 pods)   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
│         │                │                │         │
│         └────────────────┼────────────────┘         │
│                          │                          │
│                ┌─────────────────┐                 │
│                │ LLM Pipeline     │                 │
│                │ (CronJob)        │                 │
│                │ Every 6 hours   │                 │
│                └─────────────────┘                 │
└─────────────────────────────────────────────────────┘
```

### Manual Deployment Steps

#### 1. Create Namespace

```bash
kubectl apply -f k8s/01-namespace.yaml
```

#### 2. Create ConfigMap and Secrets

```bash
# Update API key in k8s/02-configmap-secret.yaml
kubectl apply -f k8s/02-configmap-secret.yaml
```

#### 3. Create Persistent Volume

```bash
kubectl apply -f k8s/03-persistent-volume.yaml
```

#### 4. Deploy Services

```bash
# Deploy in order
kubectl apply -f k8s/04-rag-service.yaml
kubectl apply -f k8s/06-data-service.yaml
kubectl apply -f k8s/07-frontend.yaml
kubectl apply -f k8s/05-llm-pipeline.yaml
```

#### 5. Deploy Ingress

```bash
kubectl apply -f k8s/08-ingress.yaml
```

### Accessing the Application

```bash
# Get NodePort
kubectl get svc -n rfqxpert

# Access via NodePort
# Frontend: http://localhost:30080
# RAG Service: http://localhost:30080/api/rag
# Data Service: http://localhost:30080/api/data
```

### Monitoring

```bash
# View pods
kubectl get pods -n rfqxpert

# View services
kubectl get services -n rfqxpert

# View deployments
kubectl get deployments -n rfqxpert

# View logs
kubectl logs -f deployment/rag-service -n rfqxpert
kubectl logs -f deployment/data-service -n rfqxpert
kubectl logs -f deployment/frontend -n rfqxpert
```

### Scaling

```bash
# Scale RAG service
kubectl scale deployment rag-service --replicas=3 -n rfqxpert

# Scale data service
kubectl scale deployment data-service --replicas=3 -n rfqxpert

# Scale frontend
kubectl scale deployment frontend --replicas=3 -n rfqxpert
```

### Horizontal Pod Autoscaler

Create HPA for automatic scaling:

```bash
kubectl autoscale deployment rag-service \
  --cpu-percent=70 \
  --min=2 \
  --max=10 \
  -n rfqxpert
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
# Pod resources
kubectl top pods -n rfqxpert

# Node resources
kubectl top nodes

# Describe pod
kubectl describe pod <pod-name> -n rfqxpert

# Check events
kubectl get events -n rfqxpert --sort-by=.metadata.creationTimestamp
```

### Cleanup

```bash
# Delete namespace (removes everything)
kubectl delete namespace rfqxpert

# Delete specific resources
kubectl delete -f k8s/
```

---

## ☁️ AWS Cloud Deployment

### Quick Start

```bash
# 1. Launch EC2 t2.micro instance (Free Tier)
# 2. Configure Security Groups (ports 22, 3000, 8000, 8001)
# 3. Connect via SSH
ssh -i your-key.pem ec2-user@your-instance-ip

# 4. Run deployment script
git clone <repository-url>
cd RFQXpert
chmod +x deploy-aws.sh
./deploy-aws.sh
```

### AWS Free Tier Limits

- **750 hours/month** of t2.micro instances
- **30 GB** of EBS General Purpose (gp2) storage
- **2 million I/Os** with EBS
- **15 GB** of bandwidth out per month

### Step-by-Step AWS Setup

#### 1. Launch EC2 Instance

```bash
# Configuration
AMI: Amazon Linux 2
Instance: t2.micro
Storage: 30GB gp2
Security Group:
  - SSH (22) - Your IP
  - HTTP (80) - 0.0.0.0/0
  - Custom TCP (3000) - 0.0.0.0/0
  - Custom TCP (8000) - 0.0.0.0/0
  - Custom TCP (8001) - 0.0.0.0/0
```

#### 2. Connect and Setup

```bash
# Connect via SSH
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo yum install -y git
```

#### 3. Deploy Application

```bash
# Clone repository
git clone <repository-url>
cd RFQXpert

# Create .env file
echo "GEMINI_API_KEY=your_actual_api_key" > .env

# Build and start
docker-compose build
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

#### 4. Access Application

```bash
# Get public IP
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Access URLs
# Frontend: http://YOUR_PUBLIC_IP:3000
# RAG Service: http://YOUR_PUBLIC_IP:8000
# Data Service: http://YOUR_PUBLIC_IP:8001
```

### Cost Optimization

#### Auto-Shutdown Script

```bash
# Create shutdown script
cat > /home/ec2-user/auto-shutdown.sh << 'EOF'
#!/bin/bash
CURRENT_HOUR=$(date +%H)
if [ $CURRENT_HOUR -ge 22 ] || [ $CURRENT_HOUR -lt 6 ]; then
    echo "Shutting down for cost optimization..."
    sudo shutdown -h now
fi
EOF

# Make executable
chmod +x /home/ec2-user/auto-shutdown.sh

# Add to crontab
(crontab -l 2>/dev/null; echo "0 */6 * * * /home/ec2-user/auto-shutdown.sh") | crontab -
```

### Security Configuration

#### Security Group Rules

```json
{
  "SecurityGroupRules": [
    {
      "IpProtocol": "tcp",
      "FromPort": 22,
      "ToPort": 22,
      "CidrIp": "YOUR_IP/32",
      "Description": "SSH access from your IP"
    },
    {
      "IpProtocol": "tcp",
      "FromPort": 3000,
      "ToPort": 3000,
      "CidrIp": "0.0.0.0/0",
      "Description": "Frontend access"
    },
    {
      "IpProtocol": "tcp",
      "FromPort": 8000,
      "ToPort": 8000,
      "CidrIp": "0.0.0.0/0",
      "Description": "RAG service access"
    },
    {
      "IpProtocol": "tcp",
      "FromPort": 8001,
      "ToPort": 8001,
      "CidrIp": "0.0.0.0/0",
      "Description": "Data service access"
    }
  ]
}
```

### Monitoring Setup

```bash
# Install CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Configure monitoring
# - CPU Utilization
# - Memory Usage
# - Disk Usage
# - Network I/O
```

### Backup Strategy

#### Create EBS Snapshot

```bash
# Manual snapshot
aws ec2 create-snapshot \
  --volume-id vol-xxxxx \
  --description "RFQXpert backup"

# Automated snapshot script
cat > /home/ec2-user/backup.sh << 'EOF'
#!/bin/bash
# Backup data directory to S3
tar -czf /tmp/rfqxpert-backup-$(date +%Y%m%d).tar.gz /home/ec2-user/RFQXpert/data
aws s3 cp /tmp/rfqxpert-backup-*.tar.gz s3://your-bucket-name/backups/
EOF

chmod +x /home/ec2-user/backup.sh

# Schedule daily backup
(crontab -l 2>/dev/null; echo "0 2 * * * /home/ec2-user/backup.sh") | crontab -
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy RFQXpert

on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'
          
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          
      - name: Run tests
        run: |
          pytest tests/
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push images
        run: |
          docker-compose build
          docker tag rfqxpert/rag-service:latest ${{ secrets.DOCKER_USERNAME }}/rfqxpert-rag-service:latest
          docker tag rfqxpert/llm-pipeline:latest ${{ secrets.DOCKER_USERNAME }}/rfqxpert-llm-pipeline:latest
          docker tag rfqxpert/data-service:latest ${{ secrets.DOCKER_USERNAME }}/rfqxpert-data-service:latest
          docker tag rfqxpert/frontend:latest ${{ secrets.DOCKER_USERNAME }}/rfqxpert-frontend:latest
          docker push ${{ secrets.DOCKER_USERNAME }}/rfqxpert-rag-service:latest
          docker push ${{ secrets.DOCKER_USERNAME }}/rfqxpert-llm-pipeline:latest
          docker push ${{ secrets.DOCKER_USERNAME }}/rfqxpert-data-service:latest
          docker push ${{ secrets.DOCKER_USERNAME }}/rfqxpert-frontend:latest
  
  deploy-aws:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/master'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to AWS EC2
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.AWS_HOST }}
          username: ec2-user
          key: ${{ secrets.AWS_SSH_KEY }}
          script: |
            cd RFQXpert
            git pull origin master
            docker-compose pull
            docker-compose up -d
```

### Deployment Strategies

1. **Blue-Green Deployment**
   - Deploy new version alongside old version
   - Switch traffic after validation
   - Rollback if issues occur

2. **Canary Deployment**
   - Deploy to small percentage of users
   - Monitor metrics
   - Gradually increase if successful

3. **Rolling Update**
   - Update pods one by one
   - Zero downtime
   - Automatic rollback on failure

---

## 📊 Monitoring & Logging

### Health Checks

All services expose health check endpoints:

```bash
# RAG Service
curl http://localhost:8000/health

# Data Service
curl http://localhost:8001/health

# Frontend
curl http://localhost:3000/
```

### Log Aggregation

#### Docker Logs

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f rag-service

# View logs with timestamps
docker-compose logs -t
```

#### Kubernetes Logs

```bash
# View pod logs
kubectl logs -f deployment/rag-service -n rfqxpert

# View logs from all pods
kubectl logs -l app=rag-service -n rfqxpert --all-containers=true

# Export logs to file
kubectl logs deployment/rag-service -n rfqxpert > rag-service.log
```

### Monitoring Tools

#### Prometheus Setup

```yaml
# prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: rfqxpert
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'rag-service'
        static_configs:
          - targets: ['rag-service:8000']
      - job_name: 'data-service'
        static_configs:
          - targets: ['data-service:8001']
      - job_name: 'frontend'
        static_configs:
          - targets: ['frontend:3000']
```

#### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "RFQXpert Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          "rate(http_requests_total[5m])"
        ]
      },
      {
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          "rate(http_requests_total{status=~\"5..\"}[5m])"
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          "histogram_quantile(0.95, http_request_duration_seconds_bucket)"
        ]
      }
    ]
  }
}
```

### Alerting Rules

```yaml
# alerts.yaml
groups:
  - name: rfqxpert_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        annotations:
          summary: "High error rate detected"
          
      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes > 0.9
        for: 5m
        annotations:
          summary: "High memory usage"
          
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        annotations:
          summary: "Service is down"
```

---

## 🔒 Security Best Practices

### 1. Environment Variables

Never commit sensitive data to version control:

```bash
# .gitignore
.env
*.pem
*.key
secrets/
```

### 2. API Key Management

#### Docker

```bash
# Use Docker secrets
echo "your_api_key" | docker secret create gemini_api_key -
docker service create --secret gemini_api_key ...
```

#### Kubernetes

```bash
# Create secret
kubectl create secret generic rfqxpert-secrets \
  --from-literal=GEMINI_API_KEY=your_key \
  -n rfqxpert

# Use in deployment
env:
  - name: GEMINI_API_KEY
    valueFrom:
      secretKeyRef:
        name: rfqxpert-secrets
        key: GEMINI_API_KEY
```

### 3. Network Policies

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

### 4. RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: rfqxpert-role
  namespace: rfqxpert
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rfqxpert-role-binding
  namespace: rfqxpert
subjects:
- kind: ServiceAccount
  name: rfqxpert-sa
  namespace: rfqxpert
roleRef:
  kind: Role
  name: rfqxpert-role
  apiGroup: rbac.authorization.k8s.io
```

### 5. Container Security

```dockerfile
# Use non-root user
RUN adduser -D -u 1000 appuser
USER appuser

# Scan for vulnerabilities
# Use Trivy
docker run aquasec/trivy image rfqxpert/rag-service:latest
```

### 6. TLS/SSL

```yaml
# TLS Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rfqxpert-ingress
  namespace: rfqxpert
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - rfqxpert.example.com
    secretName: rfqxpert-tls
  rules:
  - host: rfqxpert.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 3000
```

---

## 💾 Backup & Disaster Recovery

### Backup Strategy

#### 1. Data Backup

```bash
# Backup script
#!/bin/bash
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/rfqxpert"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup data
tar -czf $BACKUP_DIR/data-$BACKUP_DATE.tar.gz \
  data/ \
  RAG/data/

# Backup configuration
tar -czf $BACKUP_DIR/config-$BACKUP_DATE.tar.gz \
  .env \
  docker-compose.yml \
  k8s/

# Keep only last 30 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_DATE"
```

#### 2. Automated Backup (Cron)

```bash
# Add to crontab
0 2 * * * /path/to/backup-script.sh
```

#### 3. Kubernetes Backup

```bash
# Backup PVC
kubectl exec -n rfqxpert deployment/rag-service -- tar czf - /app/data > backup.tar.gz

# Restore
kubectl exec -i -n rfqxpert deployment/rag-service -- tar xzf - < backup.tar.gz
```

### Disaster Recovery

#### Recovery Plan

1. **RTO (Recovery Time Objective)**: 4 hours
2. **RPO (Recovery Point Objective)**: 24 hours
3. **Backup Frequency**: Daily
4. **Retention**: 30 days

#### Recovery Steps

```bash
# 1. Restore data
tar -xzf backup.tar.gz

# 2. Restart services
docker-compose up -d

# 3. Verify services
curl http://localhost:3000/
curl http://localhost:8000/health
curl http://localhost:8001/health

# 4. Run health checks
docker-compose ps
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Port Conflicts

```bash
# Check if ports are in use
lsof -i :3000
lsof -i :8000
lsof -i :8001

# Kill process
kill -9 <PID>
```

#### 2. Container Won't Start

```bash
# Check logs
docker-compose logs <service-name>

# Check container status
docker ps -a

# Inspect container
docker inspect <container-id>
```

#### 3. API Key Issues

```bash
# Verify .env file
cat .env

# Check environment variables
docker-compose exec rag-service env | grep GEMINI

# Test API key
curl -H "Authorization: Bearer $GEMINI_API_KEY" ...
```

#### 4. Persistent Volume Issues

```bash
# Check PVC status (Kubernetes)
kubectl get pvc -n rfqxpert
kubectl describe pvc -n rfqxpert

# Check PV status
kubectl get pv

# Recreate PVC if needed
kubectl delete pvc -n rfqxpert --all
kubectl apply -f k8s/03-persistent-volume.yaml
```

#### 5. Network Issues

```bash
# Check network
docker network ls
docker network inspect rfqxpert-network

# Recreate network
docker network rm rfqxpert-network
docker-compose up -d
```

### Debug Commands

#### Docker

```bash
# Exec into container
docker-compose exec rag-service bash

# Check resource usage
docker stats

# System information
docker system df
docker system info
```

#### Kubernetes

```bash
# Get detailed pod information
kubectl describe pod <pod-name> -n rfqxpert

# Check resource usage
kubectl top pod <pod-name> -n rfqxpert

# Check events
kubectl get events -n rfqxpert --sort-by=.metadata.creationTimestamp

# Exec into pod
kubectl exec -it deployment/rag-service -n rfqxpert -- bash
```

---

## 📚 Additional Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Google Gemini API](https://ai.google.dev/docs)

### Tools
- **kubectl**: Kubernetes CLI
- **Docker Desktop**: Local container runtime
- **Helm**: Kubernetes package manager
- **Minikube**: Local Kubernetes cluster
- **k9s**: Terminal UI for Kubernetes

### Best Practices
- Always use version tags for images
- Implement proper resource limits
- Use secrets management
- Enable health checks
- Set up monitoring
- Regular backups
- Document everything

---

## 🎯 Deployment Decision Matrix

| Criteria | Docker Compose | Kubernetes | AWS EC2 |
|----------|----------------|------------|---------|
| **Complexity** | Low | High | Medium |
| **Cost** | Free | Free (local) | Free tier (12 months) |
| **Production Ready** | Limited | Yes | Yes |
| **Scaling** | Manual | Auto | Manual |
| **Setup Time** | 5 min | 30 min | 20 min |
| **Maintenance** | Low | Medium | Medium |
| **Use Case** | Development | Production | Hybrid |

---

## 📞 Support & Contributing

### Getting Help
1. Check troubleshooting section
2. Review logs
3. Check GitHub issues
4. Contact maintainers

### Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push and create pull request

---

## 🎉 Quick Reference

```bash
# Docker Quick Commands
docker-compose up -d                  # Start all services
docker-compose logs -f                # View logs
docker-compose ps                     # Check status
docker-compose restart rag-service    # Restart service
docker-compose down                   # Stop services

# Kubernetes Quick Commands
kubectl apply -f k8s/                 # Deploy everything
kubectl get pods -n rfqxpert          # View pods
kubectl logs -f deployment/rag-service -n rfqxpert  # View logs
kubectl delete namespace rfqxpert     # Remove everything

# AWS Quick Commands
ssh -i key.pem ec2-user@IP            # Connect to instance
docker-compose up -d                  # Start services
docker-compose logs -f                # View logs
```

---

**Last Updated**: December 2024  
**Version**: 1.0  
**Status**: Production Ready ✅

