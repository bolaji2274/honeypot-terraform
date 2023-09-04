provider "aws" {
  region = "us-east-2"
}

# creating a main vpv for the network

resource "aws_vpc" "main-vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  tags = {
    Name = "main-vpc"
  }
}

# creating an internet gateway by linking to the main vpc

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "IGW"
  }
  depends_on = [
    aws_vpc.main-vpc
  ]
}

# create a public subnet within our VPC for
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-subnet"
  }
  depends_on = [
    aws_vpc.main-vpc,
    aws_internet_gateway.igw
  ]
}
resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.main-vpc.id

  tags = {
    Name = "private-subnet"
  }
  depends_on = [
    aws_subnet.public_subnet
  ]
}

resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id           = aws_internet_gateway.igw.id
    # network_interface_id = aws_instance.pfsense-firewall.id
  }

  tags = {
    Name = "Route-public"
  }
  depends_on = [
    aws_vpc.main-vpc,
    aws_internet_gateway.igw,
    aws_subnet.public_subnet
  ]
}


resource "aws_route_table" "route-private" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_internet_gateway.igw.id
    network_interface_id = aws_network_interface.pfsense-internal.id
  }

  tags = {
    Name = "Route-public"
  }
  depends_on = [
    aws_vpc.main-vpc,
    aws_subnet.private_subnet
  ]
}

resource "aws_route_table_association" "route2private"{
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route-private.id

  depends_on = [
    aws_route_table.route-private
  ]
}
resource "aws_network_interface" "pfsense-internal" {
  subnet_id       = aws_subnet.private_subnet.id
  private_ips     = ["10.0.2.5"]
  security_groups = [aws_security_group.pfsense_sg.id]

  attachment {
    instance     = aws_instance.pfsense-firewall.id
    device_index = 1
  }
  tags = {
    Name = "Pfsense-internal-network-interface-card"
  }
}
resource "aws_security_group" "pfsense_sg" {
  name        = "pfsense-sg"
  description = "Pfsense Security Group"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "All outgoing traffic is opened enabled"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Pfsense-sg"
  }
}

# create a pfsense inside our public subnet

resource "aws_instance" "pfsense-firewall" {
  ami           = "ami-0ce37c6b62e18d57c"
  instance_type = "c5.large"
  key_name      = "pfsense"
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "Pfsense"
  }

  vpc_security_group_ids = [aws_security_group.pfsense_sg.id]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

}
resource "aws_instance" "testing" {
  ami           = "ami-0430580de6244e02e"
  instance_type = "t2.micro"
  key_name         = "pfsense"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.test.id]
  tags = {
    Name = "Testing"
  }
}
resource "aws_security_group" "test" {
  name        = "testing-sg"
  description = "testing Security Group"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_route_table_association" "route2public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route-public.id

  depends_on = [
    aws_route_table.route-public
  ]
}


output "public_ip" {
  value = aws_instance.pfsense-firewall.public_ip
  description = "This is the public ip address of a web-server"
}
output "password" {
  value = aws_instance.pfsense-firewall.password_data
  description = "This is the public ip address of a web-server"
}