#!/bin/bash

# Docker Network Fix Script for RFQXpert
# This script helps resolve Docker Hub connectivity issues

set -e

echo "🔧 Docker Network Fix Script"
echo "============================"

# Check Docker status
echo "📊 Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo "✅ Docker is running"

# Test network connectivity
echo "🌐 Testing network connectivity..."
if ping -c 1 docker.io > /dev/null 2>&1; then
    echo "✅ docker.io is reachable"
else
    echo "⚠️  docker.io is not reachable"
    echo "   This might be a temporary network issue"
fi

# Check DNS resolution
echo "🔍 Checking DNS resolution..."
if nslookup docker.io > /dev/null 2>&1; then
    echo "✅ DNS resolution working"
else
    echo "❌ DNS resolution failed"
    echo "   Try: sudo systemctl restart systemd-resolved"
fi

# Test Docker Hub connectivity
echo "🐳 Testing Docker Hub connectivity..."
if docker pull hello-world > /dev/null 2>&1; then
    echo "✅ Docker Hub connectivity working"
    echo "🎉 You can now build your images!"
else
    echo "❌ Docker Hub connectivity failed"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "1. Restart Docker Desktop"
    echo "2. Check your internet connection"
    echo "3. Try using a VPN if behind corporate firewall"
    echo "4. Check Docker Desktop proxy settings"
    echo "5. Wait a few minutes and try again"
    echo ""
    echo "🔄 Alternative solutions:"
    echo "1. Use Google Container Registry:"
    echo "   docker pull gcr.io/distroless/python3-debian11"
    echo "2. Use local images if available"
    echo "3. Build from source if needed"
fi

# Show available images
echo ""
echo "📦 Available Docker images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10

echo ""
echo "🚀 Once connectivity is restored, run:"
echo "   docker-compose build"
echo "   docker-compose up -d"
