# RAG Service Dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install additional dependencies for RAG service
RUN pip install --no-cache-dir \
    PyPDF2 \
    python-docx \
    scikit-learn \
    numpy

# Copy RAG service code
COPY RAG/ ./RAG/

# Create data directory
RUN mkdir -p /app/data

# Copy shared data files
COPY data/companydata.json ./data/
# Flag file will be created at runtime by the service

# Expose port
EXPOSE 8000

# Set environment variables
ENV PYTHONPATH=/app
ENV DATA_DIR=/app/data

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Run the application
CMD ["uvicorn", "RAG.main:app", "--host", "0.0.0.0", "--port", "8000"]
