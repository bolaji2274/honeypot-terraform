# resource "aws_instance" "pfsense" {
#   ami = "ami-0f1c68e571ab71af6"
#   instance_type = "m5.large"
#   key_name = "web"
#   subnet_id = aws_subnet.main-subnet.id

#   tags = {
#     Name = "Pfsense"
#   }

#     root_block_device {
#     volume_type           = "gp2"
#     volume_size           = 30
#     delete_on_termination = true
#   }
# }