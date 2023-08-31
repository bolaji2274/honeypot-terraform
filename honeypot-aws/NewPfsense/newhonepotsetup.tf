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

resource "aws_security_group" "pfsense_sg" {
  name        = "pfsense-sg"
  description = "Pfsense Security Group"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 443
    to_port    = 443
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "All outgoing traffic is opened enabled"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
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
  
  # network_interface {
  #   device_index = 0
  #   # network_interface_id = aws_network_interface.lan.id
  #   # device_index = 0
  #   network_card_index = 0
  #   network_interface_id = aws_network_interface.lan.id
  # }
}

# resource "aws_network_interface" "lan" {
#   subnet_id = aws_subnet.private_subnet.id
#   # private_ip = ["10.0.2.5"]
#   private_ip = "10.0.2.5"
# }
data "aws_network_interfaces" "example" {
  tags = {
    Name = "test"
  }
}

output "example1" {
  value = data.aws_network_interfaces.example.ids
}
# create a private subnet for our for our 

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.main-vpc.id
  # availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet"
  }
  depends_on = [
    aws_subnet.public_subnet
  ]
}


# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "igw"
#   }

#   depends_on = [
#     aws_vpc.vpc
#   ]
# }


resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
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