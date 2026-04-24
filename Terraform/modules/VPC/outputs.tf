output "vpc_id" {
    description = "ID of VPC"
    value = aws_vpc.main.id
  
}

output "private_subnet_id" {
    description = "ID of private subnet"
    value = aws_subnet.private_subnet1.id
}

output "public_subnet_id" {
    description = "ID of public subnet"
    value = aws_subnet.public_subnet1.id
}

output "igw_id" {
    description = "ID of internet gateway"
    value = aws_internet_gateway.main.id
}
