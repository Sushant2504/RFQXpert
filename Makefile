# RFQXpert Docker Makefile
# Provides convenient commands for Docker operations

.PHONY: help build up down logs clean restart status health

# Default target
help:
	@echo "RFQXpert Docker Commands"
	@echo "======================="
	@echo "build     - Build all Docker images"
	@echo "up        - Start all services"
	@echo "up-pipeline - Start all services including ML pipeline"
	@echo "down      - Stop all services"
	@echo "logs      - View logs for all services"
	@echo "logs-rag  - View RAG service logs"
	@echo "logs-llm  - View LLM pipeline logs"
	@echo "logs-data - View data service logs"
	@echo "logs-frontend - View frontend logs"
	@echo "restart   - Restart all services"
	@echo "status    - Show service status"
	@echo "health    - Check service health"
	@echo "clean     - Remove all containers and images"
	@echo "shell-rag - Access RAG service shell"
	@echo "shell-llm - Access LLM pipeline shell"
	@echo "shell-data - Access data service shell"
	@echo "shell-frontend - Access frontend shell"

# Build all images
build:
	@echo "🔨 Building all Docker images..."
	docker-compose build

# Start all services
up:
	@echo "🚀 Starting all services..."
	docker-compose up -d

# Start all services including ML pipeline
up-pipeline:
	@echo "🚀 Starting all services with ML pipeline..."
	docker-compose --profile pipeline up -d

# Stop all services
down:
	@echo "🛑 Stopping all services..."
	docker-compose down

# View logs for all services
logs:
	@echo "📋 Viewing logs for all services..."
	docker-compose logs -f

# View logs for specific services
logs-rag:
	@echo "📋 Viewing RAG service logs..."
	docker-compose logs -f rag-service

logs-llm:
	@echo "📋 Viewing LLM pipeline logs..."
	docker-compose logs -f llm-pipeline

logs-data:
	@echo "📋 Viewing data service logs..."
	docker-compose logs -f data-service

logs-frontend:
	@echo "📋 Viewing frontend logs..."
	docker-compose logs -f frontend

# Restart all services
restart:
	@echo "🔄 Restarting all services..."
	docker-compose restart

# Show service status
status:
	@echo "📊 Service Status:"
	docker-compose ps

# Check service health
health:
	@echo "🏥 Checking service health..."
	@echo "RAG Service:"
	@docker-compose exec rag-service curl -f http://localhost:8000/ || echo "❌ RAG Service unhealthy"
	@echo "Data Service:"
	@docker-compose exec data-service curl -f http://localhost:8001/data || echo "❌ Data Service unhealthy"
	@echo "Frontend:"
	@docker-compose exec frontend wget --no-verbose --tries=1 --spider http://localhost:3000/ || echo "❌ Frontend unhealthy"

# Clean up everything
clean:
	@echo "🧹 Cleaning up Docker resources..."
	docker-compose down -v --remove-orphans
	docker-compose down --rmi all
	docker system prune -f

# Access service shells
shell-rag:
	@echo "🐚 Accessing RAG service shell..."
	docker-compose exec rag-service bash

shell-llm:
	@echo "🐚 Accessing LLM pipeline shell..."
	docker-compose exec llm-pipeline bash

shell-data:
	@echo "🐚 Accessing data service shell..."
	docker-compose exec data-service bash

shell-frontend:
	@echo "🐚 Accessing frontend shell..."
	docker-compose exec frontend sh

# Development helpers
dev-build:
	@echo "🔨 Building with no cache..."
	docker-compose build --no-cache

dev-up:
	@echo "🚀 Starting in development mode..."
	docker-compose up

# Production helpers
prod-build:
	@echo "🔨 Building for production..."
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml build

prod-up:
	@echo "🚀 Starting in production mode..."
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
