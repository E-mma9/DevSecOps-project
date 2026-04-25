output "sg_id" {
  description = "ID van de security group — doorgegeven aan de EKS module"
  value       = aws_security_group.main.id
}
