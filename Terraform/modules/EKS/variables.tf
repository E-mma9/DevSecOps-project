variable "cluster_name" {
  description = "Naam van het EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN van de IAM rol voor de EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "ARN van de IAM rol voor de EKS worker nodes"
  type        = string
}

variable "subnet_ids" {
  description = "Lijst van private subnet IDs waar de worker nodes in worden geplaatst"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Lijst van security group IDs die aan het EKS cluster worden gekoppeld"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes versie voor het EKS cluster"
  type        = string
  default     = "1.29" # gebruik altijd een ondersteunde versie, 1.21 is end-of-life
}

variable "instance_type" {
  description = "EC2 instance type voor de worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Gewenst aantal worker nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimaal aantal worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximaal aantal worker nodes"
  type        = number
  default     = 2
}
