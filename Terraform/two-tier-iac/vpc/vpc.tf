#####################################
#Create VPC for entire infrastructure
#####################################

resource "aws_vpc" "main" {
    cidr_block = var.cidr_block

    tags = {
        "Name" = "Poppy Carts VPC"
    }
}

# Connect to the internet via IGW

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        "Name" = "Poppy Carts IGW"
    }
}