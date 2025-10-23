# Data Service Dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy data service code
COPY data/main.py ./data/

# Create data directory and copy all data files
RUN mkdir -p /app/data
COPY data/*.json ./data/

# Expose port
EXPOSE 8001

# Set environment variables
ENV PYTHONPATH=/app
ENV DATA_DIR=/app/data

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/data || exit 1

# Run the application
CMD ["uvicorn", "data.main:app", "--host", "0.0.0.0", "--port", "8001"]
