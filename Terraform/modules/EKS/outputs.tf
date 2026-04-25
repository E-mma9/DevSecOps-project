output "cluster_name" {
  description = "Naam van het aangemaakte EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "API server endpoint van het EKS cluster — vereist voor kubectl configuratie"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA certificaat van het cluster — vereist voor kubectl authenticatie"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}
