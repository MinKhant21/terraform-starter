
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
  id = var.vpc_id
}
