variable "cluster_name" {
    description = "name of cluster"
    default = "devsecops-cluster"
}

variable "cluster_role_arn" {  # ARN of the control plane
    description = "ARN of the cluster role"
  
}

variable "node_role_arn" { 
    description = "ARN of the node role"
    
}