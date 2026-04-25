output "cluster_name" {
  description = "Naam van het EKS cluster — doorgegeven aan de EKS module"
  value       = var.cluster_name
}

output "cluster_role_arn" {
  description = "ARN van de LabRole — gebruikt als EKS control plane rol"
  value       = data.aws_iam_role.lab_role.arn # LabRole heeft al de benodigde EKS rechten
}

output "node_role_arn" {
  description = "ARN van de LabRole — gebruikt als EKS worker node rol"
  value       = data.aws_iam_role.lab_role.arn # zelfde rol voor nodes, Learner Lab staat geen aparte rollen toe
}
