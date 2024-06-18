terraform {
  backend "s3" {
    bucket         = "anslem-terraform-statefile-demo-2024-2"
    key            = "anslem-terraform/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "anslem-terraform-tf-state-lock"
  }
}