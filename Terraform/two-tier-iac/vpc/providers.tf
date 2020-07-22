provider "aws" {
    region = var.region

    version = "~> 2.69"
}

terraform {
    backend "s3" {
        bucket = "poppy-carts-terraform-backend"
        key = "two-tier-iac/vpc/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "poppy-carts-locks"
        encrypt = true
    }
}