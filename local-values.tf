# Define Local Values in Terraform
locals {
  owners      = var.department
  environment = var.environment
  name        = "${local.owners}-${var.environment}"
  vpc_name    = "Anselme-${var.environment}-VPC"
  bastion_name = "Anselme-${var.environment}-Bastion"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
} 