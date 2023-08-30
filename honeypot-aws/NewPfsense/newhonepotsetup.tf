provider "aws" {
  region = "us-east-2"
}

# creating a main vpv for the network

resource "aws_vpc" "main-vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = "10.0.0.0/16"
  instance_tenancy = "default"
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
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-subnet"
  }
  depends_on = [
    aws_vpc.main-vpc,
    aws_internet_gateway.igw
  ]
}
# create a pfsense inside our public subnet

resource "aws_instance" "pfsense-firewall" {
  ami = "ami-0f1c68e571ab71af6"
  instance_type = "m5.large"
  # key_name = "web"
  subnet_id = aws_subnet.public_subnet.id
  tags = {
    Name = "Pfsense"
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 30
    delete_on_termination = true
  }
}
# create a private subnet for our for our 

# resource "aws_subnet" "private_subnet" {
#   cidr_block        = "10.0.1.0/24"
#   vpc_id = aws_vpc.main-vpc.id
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "private-subnet"
#   }
#   depends_on = [
#     aws_subnet.public_subnet
#   ]
# }