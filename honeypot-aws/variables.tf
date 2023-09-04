variable "admin_ip" {
  # Get the ip address of the system and specify it in cidr block
  default     = ["0.0.0.0/0"]
  description = "admin IP addresses in CIDR format"
}


variable "region" {
  description = "AWS region to launch servers"

  default = "us-east-1a"
}

variable "key_name" {
  default = "honeypot"
}

variable "instance_type" {
  default = "t3.large"

}



## cloud-init configuration ##
variable "timezone" {
  default = "UTC"
}

variable "linux_password" {
  description = "Set a password for the default user"

  validation {
    condition     = length(var.linux_password) > 0
    error_message = "Please specify a password for the default user."
  }
}

# These will go in the generated tpot.conf file 
variable "tpot_flavor" {
  default     = "STANDARD"
  description = "Specify your tpot flavor [STANDARD, HIVE, HIVE_SENSOR, INDUSTRIAL, LOG4J, MEDICAL, MINI, SENSOR]"
}

variable "web_user" {
  description = "Set a username for the web user"
}

variable "web_password" {
  description = "Set a password for the web user"

  validation {
    condition     = length(var.web_password) > 0
    error_message = "Please specify a password for the web user."
  }
}

