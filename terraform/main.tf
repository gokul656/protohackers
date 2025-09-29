provider "aws" {
  region = "ap-south-1"
}

# Key Pair
resource "aws_key_pair" "mykey" {
  key_name   = "nitro-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "main-vpc" }
}

# Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "main-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-gw" }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "main-rt" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "tcp_server_sg" {
  name        = "tcp-server-sg"
  description = "Allow SSH and TCP 8000"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TCP 8000"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# EC2 Instance
resource "aws_instance" "tcp_server" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.mykey.key_name
  subnet_id              = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tcp_server_sg.id]

  tags = { Name = "TCP-Server" }
}
