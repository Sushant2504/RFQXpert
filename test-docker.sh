#!/bin/bash

# RFQXpert Docker Test Script
# This script tests the Docker setup without requiring API keys

set -e

echo "🧪 RFQXpert Docker Test Script"
echo "============================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo "✅ Docker is running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed"
    exit 1
fi

echo "✅ docker-compose is available"

# Test configuration
echo "🔍 Testing Docker Compose configuration..."
if docker-compose config > /dev/null 2>&1; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration has errors"
    exit 1
fi

# Test building images (dry run)
echo "🔨 Testing Docker image builds..."

# Test RAG service build
echo "  - Testing RAG service build..."
if docker-compose build rag-service --no-cache > /dev/null 2>&1; then
    echo "    ✅ RAG service builds successfully"
else
    echo "    ❌ RAG service build failed"
    exit 1
fi

# Test data service build
echo "  - Testing data service build..."
if docker-compose build data-service --no-cache > /dev/null 2>&1; then
    echo "    ✅ Data service builds successfully"
else
    echo "    ❌ Data service build failed"
    exit 1
fi

# Test frontend build
echo "  - Testing frontend build..."
if docker-compose build frontend --no-cache > /dev/null 2>&1; then
    echo "    ✅ Frontend builds successfully"
else
    echo "    ❌ Frontend build failed"
    exit 1
fi

# Test LLM pipeline build
echo "  - Testing LLM pipeline build..."
if docker-compose build llm-pipeline --no-cache > /dev/null 2>&1; then
    echo "    ✅ LLM pipeline builds successfully"
else
    echo "    ❌ LLM pipeline build failed"
    exit 1
fi

echo ""
echo "🎉 All Docker builds successful!"
echo ""
echo "📋 Next Steps:"
echo "=============="
echo "1. Create a .env file with your GEMINI_API_KEY:"
echo "   echo 'GEMINI_API_KEY=your_actual_api_key' > .env"
echo ""
echo "2. Start the services:"
echo "   docker-compose up -d"
echo ""
echo "3. Or use the Makefile commands:"
echo "   make up"
echo ""
echo "4. Check service status:"
echo "   make status"
echo ""
echo "5. View logs:"
echo "   make logs"
echo ""
echo "🌐 Service URLs:"
echo "==============="
echo "Frontend:    http://localhost:3000"
echo "RAG Service: http://localhost:8000"
echo "Data Service: http://localhost:8001"
echo ""
echo "✅ Docker setup is ready!"
