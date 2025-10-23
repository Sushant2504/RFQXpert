# RFQXpert Docker Setup

This document provides instructions for running RFQXpert using Docker containers.

## 🏗️ Architecture

The application consists of 4 main services:

1. **RAG Service** (Port 8000) - Document processing and embedding generation
2. **LLM Pipeline** - ML agents for eligibility, compliance, gap analysis, and checklist
3. **Data Service** (Port 8001) - Results serving API
4. **Frontend** (Port 3000) - Next.js UI

## 📋 Prerequisites

- Docker Desktop installed
- Docker Compose installed
- Gemini API Key (get from [Google AI Studio](https://makersuite.google.com/app/apikey))

## 🚀 Quick Start

### 1. Environment Setup

Create a `.env` file in the project root:

```bash
# Copy the example file
cp .env.example .env

# Edit the file and add your API key
GEMINI_API_KEY=your_actual_api_key_here
```

### 2. Build and Run

```bash
# Make the setup script executable
chmod +x docker-setup.sh

# Run the setup script
./docker-setup.sh

# Start all services
docker-compose up -d
```

### 3. Access the Application

- **Frontend**: http://localhost:3000
- **RAG Service**: http://localhost:8000
- **Data Service**: http://localhost:8001

## 🔧 Manual Commands

### Build Images
```bash
# Build all images
docker-compose build

# Build specific service
docker-compose build rag-service
```

### Run Services
```bash
# Start all services
docker-compose up -d

# Start with ML pipeline
docker-compose --profile pipeline up -d

# Start specific service
docker-compose up -d rag-service
```

### View Logs
```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f rag-service
docker-compose logs -f llm-pipeline
```

### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## 📁 Directory Structure

```
RFQXpert/
├── docker/
│   ├── rag-service/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   ├── llm-pipeline/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   ├── data-service/
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── frontend/
│       ├── Dockerfile
│       └── .dockerignore
├── docker-compose.yml
├── docker-setup.sh
└── .env.example
```

## 🔄 Service Dependencies

The services have the following dependencies:

1. **RAG Service** starts first and creates `rag_ready.flag`
2. **LLM Pipeline** waits for the flag, then processes ML agents
3. **Data Service** serves the processed results
4. **Frontend** provides the UI interface

## 🐛 Troubleshooting

### Common Issues

1. **Port conflicts**: Make sure ports 3000, 8000, and 8001 are available
2. **API Key issues**: Verify your GEMINI_API_KEY is correct in `.env`
3. **Build failures**: Check Docker logs for specific error messages

### Debug Commands

```bash
# Check service status
docker-compose ps

# Check service health
docker-compose exec rag-service curl -f http://localhost:8000/
docker-compose exec data-service curl -f http://localhost:8001/data

# Access service shell
docker-compose exec rag-service bash
docker-compose exec llm-pipeline bash
```

### Reset Everything

```bash
# Stop and remove everything
docker-compose down -v --remove-orphans

# Remove all images
docker-compose down --rmi all

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

## 📊 Monitoring

### Health Checks

All services include health checks:
- RAG Service: `GET /`
- Data Service: `GET /data`
- Frontend: `GET /`

### Logs

```bash
# Follow logs in real-time
docker-compose logs -f

# View logs with timestamps
docker-compose logs -t
```

## 🔒 Security Notes

- Never commit `.env` file to version control
- Use environment-specific API keys
- Consider using Docker secrets for production

## 📈 Performance Tips

1. **Resource Limits**: Add resource limits in docker-compose.yml for production
2. **Caching**: Use Docker layer caching for faster builds
3. **Multi-stage builds**: Already implemented for frontend
4. **Health checks**: Monitor service health automatically

## 🚀 Production Deployment

For production deployment:

1. Use a container registry (Docker Hub, ECR, GCR)
2. Implement proper secrets management
3. Add resource limits and health checks
4. Use Kubernetes or Docker Swarm for orchestration
5. Set up monitoring and logging

## 📞 Support

If you encounter issues:

1. Check the logs: `docker-compose logs -f`
2. Verify environment variables: `docker-compose config`
3. Test individual services: `docker-compose exec service-name bash`
4. Check Docker resources: `docker system df`
