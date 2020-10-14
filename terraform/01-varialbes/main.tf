provider "aws"{
    region = "us-east-1"
}

# VPC Creation

resource "aws_vpc" "development" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "development"
  }
}

resource "aws_subnet" "development-az1" {
  vpc_id     = aws_vpc.development.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "app-az1"
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["8.8.8.8", "8.8.4.4"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.development.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_remote"
  description = "Allow remote inbound traffic"
  vpc_id      = aws_vpc.development.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.development.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.development.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_remote"
  }
}