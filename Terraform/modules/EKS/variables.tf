variable "cluster_name" {
    description = "name of cluster"

}

variable "cluster_role_arn" {  # ARN of the control plane
    description = "ARN of the cluster role"
}

variable "node_role_arn" {  # ARN role for the worker nodes
    description = "ARN of the node role"
    
}

variable "subnet_ids" {
    description = "List of subnet IDs"
    type = list(string)
}

variable "kubernetes_version" {
    description = "Kubernetes version"
    default = "1.29"
}

variable "desired_size" {
    description = "Desired number of nodes"
    default = 1
}

variable "min_size" {
    description = "Minimum number of nodes"
    default = 1
}

variable "max_size" {
    description = "Maximum number of nodes"
    default = 2
}

variable "instance_type" {
    description = "EC2 instance types for the worker nodes"
    type = string
    default = "t3.medium"
}