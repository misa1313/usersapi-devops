resource "aws_vpc" "primary-vpc" {
  cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = "true"
  tags = {
    Name = "primary-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.primary-vpc.id
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.primary-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_security_group" "security-group" {
  name        = "allow_ssh_httpd"
  description = "Allow SSH inbound and HTTP traffic"
  vpc_id      = aws_vpc.primary-vpc.id

  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Jenkins access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_httpd"
  }
}

resource "aws_eip" "interface_eip" {
  domain                    = "vpc"
  depends_on                = [aws_instance.jenkins_server]
  network_interface         = aws_network_interface.net-interface.id
}

resource "aws_network_interface" "net-interface" {
  subnet_id   = aws_subnet.public-subnet.id
  security_groups = [aws_security_group.security-group.id]
  tags = {
    Name = "primary_network_interface"
  }
}
