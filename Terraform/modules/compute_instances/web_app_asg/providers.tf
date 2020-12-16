provider "aws" {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
#    version    = "~> 2.69"
}

terraform {
  backend "s3" {
    bucket = "poppy-carts-terraform-backend"
    key    = "two-tier-iac/asg/web_app_asg/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "poppy-carts-locks"
    encrypt        = true
  }
}