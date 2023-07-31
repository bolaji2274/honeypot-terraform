provider "aws" {
  # region = var.ec2_region
  region = "us-east-1"
}


# Creating a Main VPC
resource "aws_vpc" "main-vpc" {
  enable_dns_hostnames = true
  enable_dns_support = true
  cidr_block = "10.10.0.0/16"
}


# Creating a subnet inside our main VPC
resource "aws_subnet" "main-subnet" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet"
  }
}

# Creating an internet gateway inside main vpc
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "main-iqw"
  }
}

# Creating a route table for main vpc
resource "aws_route_table" "main-rt" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "main-rt"
  }
}

# Creating subnet association to associate our subnet with route table
resource "aws_route_table_association" "main-rt-association" {
  subnet_id = aws_subnet.main-subnet.id
  route_table_id = aws_route_table.main-rt.id
}

resource "aws_security_group" "tf-honeypot-sg" {
  name        = "tf-honeypot-sg"
  description = "Honeypot security group for inbound and outbound rule"
  # vpc_id      = var.ec2_vpc_id
  vpc_id = aws_vpc.main-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port   = 0
    to_port     = 64000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 64000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 64294
    to_port     = 64294
    protocol    = "tcp"
    cidr_blocks = var.admin_ip
    # cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 64295
    to_port     = 64295
    protocol    = "tcp"
    cidr_blocks = var.admin_ip
    # cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 64297
    to_port     = 64297
    protocol    = "tcp"
    cidr_blocks = var.admin_ip
    # cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "honeypot system"
  }

}
resource "aws_instance" "honeypot" {
  # ami           = var.ec2_ami[var.ec2_region]
  ami = "ami-05dd1b6e7ef6f8378"
  instance_type = var.ec2_instance_type
  # key_name      = var.ec2_ssh_key_name
  key_name = "web"
  # subnet_id     = var.ec2_subnet_id
  subnet_id = aws_subnet.main-subnet.id

  tags = {
    Name = "Honeypot"
  }
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }
  user_data                   = templatefile("./cloud-init.yaml", { timezone = var.timezone, password = var.linux_password, tpot_flavor = var.tpot_flavor, web_user = var.web_user, web_password = var.web_password })
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.tf-honeypot-sg.id]
  associate_public_ip_address = true
}

output "public_ip" {
  value       = aws_instance.honeypot.public_ip
  description = "The public ip address of a webserver"
}


