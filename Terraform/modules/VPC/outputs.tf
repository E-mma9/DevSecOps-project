output "vpc_id" {
    description = "ID of VPC"
    value = aws_vpc.main.id
  
}

output "subnet_id" {
    description = "ID of subnet"
    value = aws_subnet.main.id
}