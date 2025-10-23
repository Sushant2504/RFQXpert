# LLM Pipeline Dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy LLM inference code
COPY src/ ./src/

# Create data directory and copy shared data
RUN mkdir -p /app/data
COPY data/companydata.json ./data/

# Create RAG data directory and copy embeddings
RUN mkdir -p /app/RAG/data
COPY RAG/data/ ./RAG/data/

# Copy the flag file location
COPY rag_ready.flag ./rag_ready.flag 2>/dev/null || echo "Flag file not found, will be created at runtime"

# Set environment variables
ENV PYTHONPATH=/app
ENV DATA_DIR=/app/data
ENV RAG_DATA_DIR=/app/RAG/data

# Create a startup script that waits for RAG service
RUN echo '#!/bin/bash\n\
echo "Waiting for RAG service to be ready..."\n\
while [ ! -f /app/rag_ready.flag ]; do\n\
    echo "Waiting for rag_ready.flag..."\n\
    sleep 5\n\
done\n\
echo "RAG service is ready. Starting LLM pipeline..."\n\
python src/llm_inference/main.py\n\
' > /app/start.sh && chmod +x /app/start.sh

# Run the startup script
CMD ["/app/start.sh"]
