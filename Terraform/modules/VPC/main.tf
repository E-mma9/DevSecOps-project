resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name
    }
}

resource "aws_subnet" "private_subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr[0]
    availability_zone = var.subnet_az
    map_public_ip_on_launch = false
    tags = {
        Name = var.subnet_name
    }
}


resource "aws_subnet" "public_subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[0]
    availability_zone = var.subnet_az
    map_public_ip_on_launch = true
    tags = {
        Name = var.subnet_name
    }
}


resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = var.igw_name
    }
  
}



resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = var.rt_name
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.main.id
  
}

