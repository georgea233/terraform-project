# Create VPC Terraform Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.3.0"

  # VPC Parameters
  name                 = local.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  enable_dns_hostnames = true
  enable_dns_support   = true
  manage_default_security_group = false

  # Public Subnets
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true
  public_subnet_tags = {
    Name = lookup(var.public_subnet_tag, "Name", null)
  }
  enable_nat_gateway = true
  one_nat_gateway_per_az = true 

  # Private Subnets
  private_subnets = var.private_subnets
  private_subnet_tags = {
    Name = lookup(var.private_subnet_tag, "Name", null)
  }

  # Database Subnets
  database_subnets                   = var.database_subnets
  create_database_subnet_group       = var.create_database_subnet_group
  create_database_subnet_route_table = var.create_database_subnet_route_table
  database_subnet_tags = {
    Name = lookup(var.database_subnet_tag, "Name", null)
  }
}

# outputs

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# Security Group for Public Bastion Host
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name = local.bastion_name
  description = "Security Group with SSH port open for everybody (IPv4 CIDR), egress ports are all world open"
  vpc_id = module.vpc.vpc_id
  ingress_rules = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  tags = local.common_tags
}

# Security Group for Private EC2 Instances
module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name = "private-sg"
  description = "Security Group with HTTP & SSH port"
  vpc_id = module.vpc.vpc_id
  ingress_rules = ["ssh-tcp", "http-80-tcp"]
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  egress_rules = ["all-all"]
  tags = local.common_tags
}

# Security Group for Private EC2 Instances
module "public_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name = "public-sg"
  description = "Security Group with HTTP, HTTPS & SSH port open"
  vpc_id = module.vpc.vpc_id
  ingress_rules = ["ssh-tcp", "http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  tags = local.common_tags
}

module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name                   = "${var.environment}-bastion-host"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  # key_name               = var.bastion_keypair
  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  tags                   = merge(local.common_tags, { Name = "${var.environment}-bastion-host" })
}


module "ec2_private" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  for_each = { for idx, subnet_id in module.vpc.private_subnets : idx => subnet_id }

  name                   = "${var.environment}-private-ec2-${each.key}"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  # key_name               = var.public-private_keypair
  subnet_id              = each.value
  vpc_security_group_ids = [module.private_sg.security_group_id]
  tags                   = merge(local.common_tags, { Name = "${var.environment}-private-ec2-${each.key}" })
}

module "ec2_public" {
  depends_on = [ module.vpc ]
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  for_each = { for idx, subnet_id in module.vpc.public_subnets : idx => subnet_id }

  name                   = "${var.environment}-public-ec2-${each.key}"
  ami                    = data.aws_ami.amzlinux2.id
  instance_type          = var.instance_type
  # key_name               = var.public-private_keypair
  subnet_id              = each.value
  vpc_security_group_ids = [module.public_sg.security_group_id]
  tags                   = merge(local.common_tags, { Name = "${var.environment}-public-ec2-${each.key}" })
}

# S3 Bucket

module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
  
  bucket = "jjtech-terraform2"
  
  block_public_acls = true
  
  versioning = {
    enabled = true
  }
}

