terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"  # Paris
}

# Clé SSH pour se connecter au serveur
resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer"
  public_key = file("~/.ssh/ec2-deployer.pub")
}

# Pare-feu : ouvre les ports 80 (HTTP) et 22 (SSH)
resource "aws_security_group" "web" {
  name        = "docker-project-sg"
  description = "HTTP + SSH"

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Serveur EC2 t2.micro (Free Tier)
resource "aws_instance" "web" {
  ami           = "ami-04c332520bd9cedb4"  # Ubuntu 22.04 Paris
  instance_type = "t3.micro"               # Free Tier eligible
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  # Installe Docker au premier démarrage
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker ubuntu
    apt-get install -y docker-compose-plugin
  EOF

  tags = {
    Name = "docker-project"
  }
}

# IP fixe pour le serveur
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"
}