#!/bin/bash

# RFQXpert AWS EC2 Deployment Script
# Deploy to AWS EC2 Free Tier (t2.micro)

set -e

echo "🚀 RFQXpert AWS EC2 Deployment"
echo "=============================="

# Check if running on EC2
if ! curl -s http://169.254.169.254/latest/meta-data/instance-id > /dev/null 2>&1; then
    echo "⚠️  This script is designed to run on AWS EC2"
    echo "Please launch an EC2 t2.micro instance first"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
sudo yum update -y

# Install Docker
echo "🐳 Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
echo "📥 Installing Git..."
sudo yum install -y git

# Clone or upload your project
echo "📁 Setting up project..."
if [ ! -d "RFQXpert" ]; then
    echo "Please upload your RFQXpert project to this EC2 instance"
    echo "You can use SCP, SFTP, or Git clone"
    exit 1
fi

cd RFQXpert

# Create .env file
echo "🔑 Setting up environment variables..."
if [ ! -f .env ]; then
    echo "Please create .env file with your GEMINI_API_KEY"
    echo "Example: echo 'GEMINI_API_KEY=your_key_here' > .env"
    exit 1
fi

# Build and start services
echo "🔨 Building Docker images..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "✅ Deployment Complete!"
echo "======================"
echo "🌐 Your application is available at:"
echo "   Frontend:    http://$PUBLIC_IP:3000"
echo "   RAG Service: http://$PUBLIC_IP:8000"
echo "   Data Service: http://$PUBLIC_IP:8001"
echo ""
echo "🔒 Security Group Configuration:"
echo "   Make sure your EC2 security group allows:"
echo "   - Port 22 (SSH)"
echo "   - Port 3000 (Frontend)"
echo "   - Port 8000 (RAG Service)"
echo "   - Port 8001 (Data Service)"
echo ""
echo "📊 Monitor your deployment:"
echo "   docker-compose ps"
echo "   docker-compose logs -f"
echo ""
echo "💰 Cost Optimization Tips:"
echo "   - Use t2.micro instance (free tier)"
echo "   - Enable CloudWatch monitoring"
echo "   - Set up auto-shutdown during non-business hours"
echo "   - Use EBS gp2 storage (30GB free)"
