###############################
# Create a route that connects
# Public subnets to the IGW
###############################

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    tags = {
        "Name" = "PublicRouteTable"
    }
}

resource "aws_route" "public_internet_gateway" {
    route_table_id          = aws_route_table.public.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
    count           = 2
    subnet_id       = element(aws_subnet.public.*.id, count.index)
    route_table_id  = aws_route_table.public.id
}

###############################
# Create a route that connects
# Private subnets through NAT
# Gateway to the internet
###############################

resource "aws_route_table" "private" {
    count   = 1
    vpc_id  = aws_vpc.main.id

    tags = {
        "Name" = "PrivateRouteTable - element(var.availability_zones, count.index)"
    }
}

resource "aws_route" "nat_gateway" {
    count                   = 1
    route_table_id          = element(aws_route_table.private.*.id, count.index)
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
    count                   = 2
    subnet_id               = element(aws_subnet.private.*.id, count.index)
    route_table_id          = element(aws_route_table.private.*.id, count.index)
}