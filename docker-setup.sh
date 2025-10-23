#!/bin/bash

# RFQXpert Docker Setup Script
# This script helps you build and run the RFQXpert application using Docker

set -e

echo "🚀 RFQXpert Docker Setup"
echo "========================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "📝 Please edit .env file and add your GEMINI_API_KEY"
        echo "   You can get your API key from: https://makersuite.google.com/app/apikey"
        read -p "Press Enter after you've updated the .env file..."
    else
        echo "❌ .env.example file not found. Please create .env file manually."
        exit 1
    fi
fi

# Build all Docker images
echo "🔨 Building Docker images..."
docker-compose build

echo "✅ Docker images built successfully!"

# Show available commands
echo ""
echo "📋 Available Commands:"
echo "====================="
echo "1. Start all services:"
echo "   docker-compose up -d"
echo ""
echo "2. Start services with ML pipeline:"
echo "   docker-compose --profile pipeline up -d"
echo ""
echo "3. View logs:"
echo "   docker-compose logs -f [service-name]"
echo ""
echo "4. Stop all services:"
echo "   docker-compose down"
echo ""
echo "5. Rebuild and restart:"
echo "   docker-compose up -d --build"
echo ""
echo "🌐 Service URLs:"
echo "==============="
echo "Frontend:    http://localhost:3000"
echo "RAG Service: http://localhost:8000"
echo "Data Service: http://localhost:8001"
echo ""
echo "🎉 Setup complete! Run 'docker-compose up -d' to start the services."
