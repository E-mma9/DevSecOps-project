output "cluster_name" {
  description = "Naam van het EKS cluster — doorgegeven aan de EKS module"
  value       = var.cluster_name
}

output "cluster_role_arn" {
  description = "ARN van de EKS control plane IAM rol — vereist door aws_eks_cluster"
  value       = aws_iam_role.eks_cluster_role.arn # ARN van de aangemaakt rol, niet de input variable
}

output "node_role_arn" {
  description = "ARN van de EKS worker node IAM rol — vereist door aws_eks_node_group"
  value       = aws_iam_role.eks_node_role.arn # ARN van de aangemaakt rol, niet de input variable
}
