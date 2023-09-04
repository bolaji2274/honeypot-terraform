# provider "aws" {
#   region = "us-east-2"
# }


# # Creating a Main VPC
# resource "aws_vpc" "vpc" {
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   cidr_block           = "10.0.0.0/16"
# }
# # Creating an internet gateway inside main vpc
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "IGW"
#   }
# }

# # Creating a route table for main vpc
# resource "aws_route_table" "main-rt" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = "main-rt"
#   }
# }
# resource "aws_route_table_association" "main-rt-association" {
#   subnet_id      = aws_subnet.main-subnet.id
#   route_table_id = aws_route_table.main-rt.id
# }
# # # Creating a subnet inside our main VPC
# # resource "aws_subnet" "main-subnet" {
# #   vpc_id                  = aws_vpc.vpc.id
# #   cidr_block              = "10.0.1.0/24"
# #   map_public_ip_on_launch = true

# #   tags = {
# #     Name = "main-subnet"
# #   }
# # }
# # create a public subnet within our VPC for
# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "Public-subnet"
#   }
#   depends_on = [
#     aws_vpc.vpc,
#     aws_internet_gateway.igw
#   ]
# }
# # create a public subnet within our VPC for pfsense
# # resource "aws_subnet" "public_subnet" {
# #   vpc_id                  = aws_vpc.main-vpc.id
# #   cidr_block              = "10.0.1.0/24"
# #   map_public_ip_on_launch = true
# #   tags = {
# #     Name = "Public-subnet"
# #   }
# #   depends_on = [
# #     aws_vpc.main-vpc,
# #     aws_internet_gateway.igw
# #   ]
# # }

# #create a route table for the public subnet

# resource "aws_route_table" "route-public" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block           = "0.0.0.0/0"
#     gateway_id           = aws_internet_gateway.igw.id
#     # network_interface_id = aws_instance.pfsense-firewall.id
#   }

#   tags = {
#     Name = "Route-public"
#   }
#   depends_on = [
#     aws_vpc.main-vpc,
#     aws_internet_gateway.igw,
#     aws_subnet.public_subnet
#   ]
# }

# #create a private subnet for our internal network

# resource "aws_subnet" "private_subnet" {
#   cidr_block = "10.0.2.0/24"
#   vpc_id     = aws_vpc.vpc.id

#   tags = {
#     Name = "private-subnet"
#   }
#   depends_on = [
#     aws_subnet.public_subnet
#   ]
# }
# # Create a network interface for the pfsense to the internal network
# # resource "aws_instance" "pfsense-firewall" {
# #   ami           = "ami-0ce37c6b62e18d57c"
# #   instance_type = "c5.large"
# #   key_name      = "pfsense"
# #   subnet_id     = aws_subnet.public_subnet.id
# #   tags = {
# #     Name = "Pfsense"
# #   }

# #   vpc_security_group_ids = [aws_security_group.pfsense_sg.id]

# #   root_block_device {
# #     volume_type           = "gp2"
# #     volume_size           = 20
# #     delete_on_termination = true
# #   }

# # }
# # resource "aws_instance" "linux" {
# #   ami           = "ami-0430580de6244e02e"
# #   instance_type = "t2.micro"
# #   key_name         = "pfsense"
# #   subnet_id     = aws_subnet.private_subnet.id
# #   vpc_security_group_ids = [aws_security_group.linux-sg.id]
# #   tags = {
# #     Name = "Testing"
# #   }
# # }
# resource "aws_security_group" "linux-sg" {
#   name        = "testing-sg"
#   description = "testing Security Group"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#    ingress {
#         protocol = "-1"
#         from_port = 0
#         to_port = 0
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#   # ingress {
#   #   from_port   = 443
#   #   to_port     = 443
#   #   protocol    = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }
#   # ingress {
#   #   from_port   = 80
#   #   to_port     = 80
#   #   protocol    = "tcp"
#   #   cidr_blocks = ["0.0.0.0/0"]
#   # }

# }
# resource "aws_network_interface" "pfsense-internal" {
#   subnet_id       = aws_subnet.private_subnet.id
#   private_ips     = ["10.0.2.5"]
#   security_groups = [aws_security_group.pfsense_sg.id]

#   attachment {
#     # instance     = "${aws_instance.test.id}"
#     instance     = aws_instance.pfsense-firewall.id
#     device_index = 1
#   }
#   tags = {
#     Name = "Pfsense-internal-network-interface-card"
#   }
# }


# resource "aws_security_group" "pfsense_sg" {
#   name        = "pfsense-sg"
#   description = "Pfsense Security Group"
#   vpc_id      = aws_vpc.vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     description = "All outgoing traffic is opened enabled"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "Pfsense-sg"
#   }
# } 
# # create a pfsense inside our public subnet

# resource "aws_instance" "pfsense-firewall" {
#   ami           = "ami-0ce37c6b62e18d57c"
#   instance_type = "c5.large"
#   key_name      = "pfsense"
#   subnet_id     = aws_subnet.public_subnet.id
#   tags = {
#     Name = "Pfsense"
#   }

#   vpc_security_group_ids = [aws_security_group.pfsense_sg.id]

#   root_block_device {
#     volume_type           = "gp2"
#     volume_size           = 20
#     delete_on_termination = true
#   }

# }
# # Creating a linux instance inside the private subnet
# resource "aws_instance" "linux" {
#   ami           = "ami-0430580de6244e02e"
#   instance_type = "t2.micro"
#   key_name         = "pfsense"
#   subnet_id     = aws_subnet.private_subnet.id
#   vpc_security_group_ids = [aws_security_group.test.id]
#   tags = {
#     Name = "Testing"
#   }
# }
# # # Creating subnet association to associate our subnet with route table
# # resource "aws_route_table_association" "main-rt-association" {
# #   subnet_id      = aws_subnet.main-subnet.id
# #   route_table_id = aws_route_table.main-rt.id
# # }

# resource "aws_security_group" "tf-honeypot-sg" {
#   name        = "tf-honeypot-sg"
#   description = "Honeypot security group for inbound and outbound rule"
#   vpc_id = aws_vpc.vpc.id
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 0
#     to_port     = 64000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 0
#     to_port     = 64000
#     protocol    = "udp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 64294
#     to_port     = 64294
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 64295
#     to_port     = 64295
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 64297
#     to_port     = 64297
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "honeypot system"
#   }

# }


# resource "aws_instance" "honeypot" {
#   ami = "ami-04dd0542609808c50"
#   instance_type = "t3.large"
#   key_name = "pfsense"
#   subnet_id = aws_subnet.public_subnet.id

#   tags = {
#     Name = "Honeypot"
#   }
#   root_block_device {
#     volume_type           = "gp2"
#     volume_size           = 128
#     delete_on_termination = true
#   }
# #   user_data                   = templatefile("./cloud-init.yaml", { timezone = var.timezone, password = var.linux_password, tpot_flavor = var.tpot_flavor, web_user = var.web_user, web_password = var.web_password })
# #   user_data_replace_on_change = true
#   vpc_security_group_ids      = [aws_security_group.tf-honeypot-sg.id]
#   associate_public_ip_address = true
# }
# resource "aws_eip" "el_ip" {
#   instance = aws_instance.honeypot.id
#   vpc = true
# }

# output "public_ip" {
#   value       = aws_instance.honeypot.public_ip
#   description = "The public ip address of a webserver"
# }


