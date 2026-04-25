output "vpc_id" {
  description = "ID van de VPC"
  value       = aws_vpc.main.id
}

output "private_subnet1_id" {
  description = "ID van private subnet 1 (AZ 1)"
  value       = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
  description = "ID van private subnet 2 (AZ 2)"
  value       = aws_subnet.private_subnet2.id
}

output "public_subnet1_id" {
  description = "ID van public subnet 1 (AZ 1)"
  value       = aws_subnet.public_subnet1.id
}

output "public_subnet2_id" {
  description = "ID van public subnet 2 (AZ 2)"
  value       = aws_subnet.public_subnet2.id
}
