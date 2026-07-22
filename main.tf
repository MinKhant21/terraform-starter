terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.55.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_instance" "test-server" {

  ami = "ami-0b6d9d3d33ba97d99"


  key_name = "dev-key-pair"

  instance_type = "t3.micro"
  tags = {
    Name = "TestServer"
  }

  subnet_id = "subnet-0fa77d3fe18ad205b"

}