provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

resource "aws_instance" "honeypot" {
  ami           = "ami-0c94855ba95c71c99"  # Choose a suitable AMI
  instance_type = "t2.micro"  # Adjust instance type as needed

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.honeypot_profile.name
  # }

  user_data = <<-EOF
    #!/bin/bash
    echo 'Setting up honeypot...'
    # Add your setup commands here
    echo 'Honeypot setup complete.'
  EOF

  tags = {
    Name = "honeypot-instance"
  }

  vpc_security_group_ids = [aws_security_group.honeypot.id]
}

resource "aws_security_group" "honeypot" {
  name        = "honeypot-security-group"
  description = "Security group for the honeypot"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add more ingress rules as needed

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "honeypot_logs" {
  name = "/aws/instance/honeypot"
}

resource "aws_cloudwatch_log_stream" "honeypot_stream" {
  name           = "honeypot-stream"
  log_group_name = aws_cloudwatch_log_group.honeypot_logs.name
}

# resource "aws_instance" "honeypot" {
#   # ...

#   root_block_device {
#     volume_type           = "gp2"
#     volume_size           = 30
#     delete_on_termination = true
#   }

#   iam_instance_profile {
#     name = aws_iam_instance_profile.honeypot_profile.name
#   }

#   user_data = <<-EOF
#     #!/bin/bash
#     echo 'Setting up honeypot...'
#     # Add your setup commands here
#     echo 'Honeypot setup complete.'
#   EOF
# }
