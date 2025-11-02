 Terraform AWS Mini Project by Artem Melnychuk
This project provisions a basic AWS infrastructure using Terraform.
It demonstrates remote state management, modular structure, and reusable configurations.

Features

- VPC with customizable CIDR block  
- Public subnets across multiple Availability Zones  
- Internet Gateway and route tables for public access  
- EC2 web server (Amazon Linux 2) in a public subnet  
- Security Group (SG) allowing HTTP (80) and SSH (22) access  
- Elastic IP auto-assigned to the instance  
- Remote backend stored in S3 with state locking via DynamoDB

Project Structure

network/
    ── network.tf # VPC, Subnets, IGW, Route Tables
    ── network.var.tf # Variables for network configuration
    ── network-outputs.tf # Outputs for remote state

servers/
    ── servers.tf # EC2 instance, Security Group, EIP
    ── servers.outputs.tf # Outputs for server configuration

`bash
cd network / cd servers
terraform init
terraform apply

You can extend it later by adding:
    Load Balancer (ALB)
    Private subnets + NAT Gateway
    Auto Scaling Group
    RDS database integration