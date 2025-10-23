# RFQXpert AWS Free Tier Deployment Guide

## 🆓 AWS Free Tier Limits (12 months)

### **EC2 Free Tier**
- **750 hours/month** of t2.micro instances
- **30 GB** of EBS General Purpose (gp2) storage
- **2 million I/Os** with EBS
- **15 GB** of bandwidth out per month

### **RDS Free Tier** (Optional)
- **750 hours/month** of db.t2.micro instances
- **20 GB** of General Purpose (SSD) storage

## 💰 Cost Optimization Strategies

### **1. Instance Optimization**
```bash
# Use t2.micro (free tier eligible)
# Instance type: t2.micro
# vCPUs: 1
# Memory: 1 GB
# Network: Low to Moderate
```

### **2. Storage Optimization**
```bash
# Use EBS gp2 (30GB free)
# Root volume: 8GB (minimum)
# Additional volume: 22GB for data
# Total: 30GB (within free tier)
```

### **3. Auto-Shutdown Script**
```bash
#!/bin/bash
# Save as: /home/ec2-user/auto-shutdown.sh

# Shutdown during non-business hours (e.g., 10 PM - 6 AM)
CURRENT_HOUR=$(date +%H)

if [ $CURRENT_HOUR -ge 22 ] || [ $CURRENT_HOUR -lt 6 ]; then
    echo "Shutting down for cost optimization..."
    sudo shutdown -h now
fi
```

### **4. Monitoring Setup**
```bash
# Install CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Monitor CPU, Memory, Disk usage
# Set up alarms for cost control
```

## 🚀 Step-by-Step Deployment

### **Step 1: Launch EC2 Instance**
1. Go to AWS Console → EC2
2. Launch Instance
3. Choose **Amazon Linux 2 AMI**
4. Select **t2.micro** (free tier eligible)
5. Configure security group:
   - SSH (22) - Your IP
   - HTTP (80) - 0.0.0.0/0
   - Custom TCP (3000) - 0.0.0.0/0
   - Custom TCP (8000) - 0.0.0.0/0
   - Custom TCP (8001) - 0.0.0.0/0

### **Step 2: Connect and Deploy**
```bash
# Connect via SSH
ssh -i your-key.pem ec2-user@your-instance-ip

# Upload your project
scp -r -i your-key.pem RFQXpert/ ec2-user@your-instance-ip:~/

# Run deployment script
cd RFQXpert
chmod +x deploy-aws.sh
./deploy-aws.sh
```

### **Step 3: Configure Environment**
```bash
# Create .env file
echo "GEMINI_API_KEY=your_actual_api_key" > .env

# Start services
docker-compose up -d
```

## 🔒 Security Best Practices

### **1. Security Group Rules**
```json
{
  "SecurityGroupRules": [
    {
      "IpProtocol": "tcp",
      "FromPort": 22,
      "ToPort": 22,
      "IpRanges": [{"CidrIp": "YOUR_IP/32"}]
    },
    {
      "IpProtocol": "tcp",
      "FromPort": 3000,
      "ToPort": 3000,
      "IpRanges": [{"CidrIp": "0.0.0.0/0"}]
    }
  ]
}
```

### **2. IAM User Setup**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

## 📊 Monitoring and Alerts

### **1. CloudWatch Alarms**
```bash
# CPU Utilization > 80%
# Memory Utilization > 80%
# Disk Usage > 80%
# Network Out > 10GB
```

### **2. Cost Alerts**
```bash
# Set up billing alerts
# $5, $10, $20 thresholds
# Email notifications
```

## 🔄 Backup Strategy

### **1. EBS Snapshots**
```bash
# Create snapshots of important data
# Schedule automated backups
# Keep for 30 days (free tier)
```

### **2. Data Backup**
```bash
# Backup to S3 (5GB free)
# Compress data before upload
# Use lifecycle policies
```

## 🎯 Alternative Free Options

### **1. Google Cloud Platform**
- **$300 credit** for 90 days
- **Always Free** tier available
- **Compute Engine** free tier

### **2. Microsoft Azure**
- **$200 credit** for 30 days
- **Always Free** services
- **Virtual Machines** free tier

### **3. Oracle Cloud**
- **Always Free** tier
- **2 ARM-based VMs** (1/8 OCPU, 1GB RAM each)
- **No time limit**

### **4. Self-Hosted Options**
```bash
# Raspberry Pi 4 ($50 one-time cost)
# Old laptop/desktop
# Local machine with port forwarding
```

## 📈 Scaling Strategy

### **Phase 1: Free Tier (0-12 months)**
- Single t2.micro instance
- Docker Compose deployment
- Basic monitoring

### **Phase 2: Paid Tier (After 12 months)**
- t3.small instance (~$15/month)
- Load balancer
- RDS database
- CloudFront CDN

### **Phase 3: Production**
- Multi-AZ deployment
- Auto-scaling groups
- Managed services
- Professional support

## 💡 Pro Tips

1. **Use Spot Instances** for non-critical workloads
2. **Implement auto-shutdown** during non-business hours
3. **Monitor costs daily** with AWS Cost Explorer
4. **Use S3 for static assets** (5GB free)
5. **Implement caching** to reduce API calls
6. **Use CloudFront** for global distribution
7. **Set up health checks** for automatic recovery

## 🚨 Cost Control Checklist

- [ ] Use t2.micro instance only
- [ ] Enable detailed billing
- [ ] Set up cost alerts
- [ ] Monitor usage daily
- [ ] Implement auto-shutdown
- [ ] Use EBS gp2 storage
- [ ] Limit outbound bandwidth
- [ ] Regular cleanup of unused resources
- [ ] Use AWS Free Tier calculator
- [ ] Review monthly bills
