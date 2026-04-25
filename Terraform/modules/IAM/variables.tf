variable "cluster_name" {
  description = "Naam van het EKS cluster — wordt gebruikt als prefix voor de IAM rol namen"
  type        = string
  default     = "devsecops-cluster"
}
