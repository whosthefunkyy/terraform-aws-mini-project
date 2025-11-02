provider "aws" {
    region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "your-bucket-name"
    key    = "dev/servers/terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
  
 }

data "terraform_remote_state" "network" {
    backend = "s3" 
    config = {
        bucket = "your-bucket-name"
        key    = "dev/network/terraform.tfstate"
        region = "ap-southeast-1"
    }
}


data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["137112412989"] 

    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_instance" "web_server" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
    user_data              = <<EOF
    #!/bin/bash
    yum -y update
    yum -y install httpd
    myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
    echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform with Remote State"  >  /var/www/html/index.html
    service httpd start
    chkconfig httpd on
    EOF

    tags = {
        Name = "WebServerInstance"
    }
}
resource "aws_eip" "web_ip" {
instance = aws_instance.web_server.id
  domain   = "vpc"
  depends_on = [aws_instance.web_server]
}

resource "aws_security_group" "web_sg" {
    name = "webserver_sg" 
    vpc_id = data.terraform_remote_state.network.outputs.vpc_id
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

