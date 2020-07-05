##########################
# Four subnets in two AZs
# Two Public, Two Private
##########################

resource "aws_subnet" "public" {
    count                   = 2
    vpc_id                  = aws_vpc.main.id
    cidr_block              = cidrsubnet(var.cidr_block, 2, count.index)
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true

    tags = {
        "Name" = "Public subnet - element(var.availability_zones, count.index)"
    }
}

resource "aws_subnet" "private" {
    count                   = 2
    vpc_id                  = aws_vpc.main.id
    cidr_block              = cidrsubnet(var.cidr_block, 2, count.index + length(var.availability_zones))
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = false

    tags = {
        "Name" = "Private subnet - element(var.availability_zones, count.index)"
    }
}

# One NAT Gateway only
resource "aws_nat_gateway" "main" {
    count           = 1
    subnet_id       = element(aws_subnet.public.*.id, count.index)
    allocation_id   = element(aws_eip.nat.*.id, count.index)

    tags = {
        "Name" = "NAT - element(var.availability_zones, count.index)"
    }
}

# One elastic IP address
resource "aws_eip" "nat" {
    count   = 1
    vpc     = true
}