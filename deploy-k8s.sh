#!/bin/bash

# RFQXpert Kubernetes Deployment Script
# Deploy to local Kubernetes cluster (Docker Desktop)

set -e

echo "🚀 RFQXpert Kubernetes Deployment"
echo "================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if Kubernetes cluster is running
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not running. Please start Docker Desktop with Kubernetes enabled."
    exit 1
fi

echo "✅ Kubernetes cluster is running"

# Check if Docker images exist
echo "🔍 Checking Docker images..."
if ! docker images | grep -q "rfqxpert/rag-service"; then
    echo "⚠️  Docker images not found. Building images first..."
    echo "Building Docker images..."
    docker-compose build
    echo "✅ Docker images built successfully"
else
    echo "✅ Docker images found"
fi

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f k8s/01-namespace.yaml

# Create ConfigMap and Secret
echo "🔧 Creating ConfigMap and Secret..."
kubectl apply -f k8s/02-configmap-secret.yaml

# Create PersistentVolume
echo "💾 Creating PersistentVolume..."
kubectl apply -f k8s/03-persistent-volume.yaml

# Deploy RAG Service
echo "🤖 Deploying RAG Service..."
kubectl apply -f k8s/04-rag-service.yaml

# Wait for RAG service to be ready
echo "⏳ Waiting for RAG service to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/rag-service -n rfqxpert

# Deploy Data Service
echo "📊 Deploying Data Service..."
kubectl apply -f k8s/06-data-service.yaml

# Deploy Frontend
echo "🌐 Deploying Frontend..."
kubectl apply -f k8s/07-frontend.yaml

# Deploy LLM Pipeline (Job)
echo "🧠 Deploying LLM Pipeline..."
kubectl apply -f k8s/05-llm-pipeline.yaml

# Deploy Ingress
echo "🔗 Deploying Ingress..."
kubectl apply -f k8s/08-ingress.yaml

# Wait for all deployments to be ready
echo "⏳ Waiting for all services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/rag-service -n rfqxpert
kubectl wait --for=condition=available --timeout=300s deployment/data-service -n rfqxpert
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n rfqxpert

echo ""
echo "✅ Deployment Complete!"
echo "======================"

# Show service status
echo "📊 Service Status:"
kubectl get pods -n rfqxpert
kubectl get services -n rfqxpert

echo ""
echo "🌐 Access URLs:"
echo "==============="
echo "Frontend:    http://localhost:30080"
echo "RAG Service: http://localhost:30080/api/rag"
echo "Data Service: http://localhost:30080/api/data"

echo ""
echo "🔧 Useful Commands:"
echo "==================="
echo "View pods:           kubectl get pods -n rfqxpert"
echo "View services:       kubectl get services -n rfqxpert"
echo "View logs:           kubectl logs -f deployment/rag-service -n rfqxpert"
echo "Port forward:        kubectl port-forward service/frontend 3000:3000 -n rfqxpert"
echo "Delete deployment:   kubectl delete namespace rfqxpert"

echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Update the GEMINI_API_KEY in k8s/02-configmap-secret.yaml"
echo "2. Upload a document to test the RAG service"
echo "3. Check logs if any issues occur"
echo "4. Monitor resource usage with: kubectl top pods -n rfqxpert"

echo ""
echo "🎉 RFQXpert is now running on Kubernetes!"
