terraform {
    backend "s3" {
        bucket = "poppy-carts-terraform-backend"
        key = "global/backend/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "poppy-carts-locks"
        encrypt = true
    }
}