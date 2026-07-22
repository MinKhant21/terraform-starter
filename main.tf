terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.55.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Look up the AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Fetch the EXISTING VPC using data block (Fixed: replaced "resource" with "data")
data "aws_vpc" "vpc" {
  id = "vpc-088b8eb11515fe081"
}

# Optional: Fetch a subnet inside that VPC (Required for aws_instance)

# 3. Create the Security Group referencing the fetched VPC
resource "aws_security_group" "us_east_1_sg" {
  name        = "us-east-1-sg"
  description = "Allow SSH access"
  vpc_id      = data.aws_vpc.vpc.id
}

# 4. Add the Ingress Rule (Fixed: Port changed from 443 to 22 for SSH)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.us_east_1_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# 5. Launch the EC2 Instance
resource "aws_instance" "dev_server" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = "dev-key-pair"
  instance_type = "t3.micro"

  # Fixed: Attached the security group
  vpc_security_group_ids = [aws_security_group.us_east_1_sg.id]

  tags = {
    Name = "DevServer"
  }
}