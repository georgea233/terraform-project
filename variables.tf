variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zone"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "database_subnets" {
  description = "Database subnets"
  type        = list(string)
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "create_database_subnet_group" {
  description = "Create database subnet group"
  type        = bool
  default     = true
}

variable "create_database_subnet_route_table" {
  description = "Create database subnet route table"
  type        = bool
  default     = true
}

variable "department" {
  description = "Department name"
  type        = string
  default     = "JJTech"
}

# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-2"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "Dev"
}

variable "public_subnet_tag" {
  description = "Public subnet tag"
  type        = map(string)
  default = {
    Name = "Public-Subnet"
    # Name = "${element(var.subnet_name_prefix, count.index)}-Subnet-${element(var.subnet_suffix, count.index)}"
  }
}

variable "private_subnet_tag" {
  description = "Private subnet tag"
  type        = map(string)
  default = {
    Name = "Private-Subnet"
    #   Name = "${element(var.subnet_name_prefix, count.index)}-Subnet-${element(var.subnet_suffix, count.index)}"
  }
}

variable "database_subnet_tag" {
  description = "Database subnet tag"
  type        = map(string)
  default = {
    Name = "Database-Subnet"
    #     Name = "${element(var.subnet_name_prefix, count.index)}-Subnet-${element(var.subnet_suffix, count.index)}"
  }
}

# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

# AWS EC2 Instance Type

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t2.micro"  
}

# Bastion Key Pair
variable "bastion_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCbUh8wb6ZbvO606k2oEYF60mMTisBAcsLYC3xKjkeQK6sNIVf6xYXr/nsOqdBVIJuqdpDx9Ucmf3zXqt0z3PB8Qljsk4zPJXZzZmJngwHnJn1eO1SsMStpD8wM4gaQoK0IhxaHomI6QGFIXhN85P44AKjlhSeT203Y11gStBtsQ5Fczhm9Szdg5TNhnxg2H8HF/2OFjPnARWfKtucm2vI9uGRkJa5fSbAUjO8r5rgXCs0jrIL6eNkx5D5nq0A4v8ol0a9H04DJk3H3Y1o3URRa0PNeY+bjDspJzffuYN+H4ro3IfKaiceAUN+/EuUSUKjhMXj3fFmuO0mGJYYSvMEls/n0/MvgOu/kMEKTK1hN0bYNBAhjwOd7EhSjNSEHsRZJeSAsRlfPb5D3mUShqE2NjnvVTpMf7QiPlEevFjSrwvtFaK3cERK4BdoVfdNcYw7SfW3SVwmPNpDOl9vUeWgLXX9bKz3e5cOuvcj/+aG5OB0lVpFV38Eoz4BHMA2XgX0= test"
}

# Private-Public Instance Key Pair
variable "public-private_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI/qn446S10i3bh+cu5h9NOGTO/Xkkoo5dXGpR3elU7+ZWliC5o3OceUbOrR9i2u1F4QsyElpgPBfnT9NJFo/3F+vgW90/NuKf4Jsl/gs3bvSgqFarhnU3Icqj9tz4nlC1P0T5it0V+T7WMpAynKWoOLsKf9qQRI9wpJrT7M7xbLsYQV8QtsC4xizU0NdToQu1G6wMsk/bZsNnAGjwGoF0k9Q+nlTVkKsmERE3OZqz09kx9ZHsc1EW4Z6okCMKcPZYzGY0temde0iBi2/8HX1fROuneZ1sWPSOO88qeLpi3v/LzWhxaaBgP/FqNAcD2cXLFLCBTem2fL2rzBOngVb3 georgeakanza@George-2.local"
}

variable "subnet_name_prefix" {
  type    = list(string)
  default = ["Webserver-2a", "Webserver-2b", "Webserver-2a", "Webserver-2b", "Appserver-2a", "Appserver-2b"]
}
