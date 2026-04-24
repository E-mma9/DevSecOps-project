resource "aws_eks_cluster" "devsecops-app-cluster" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_node_group" "devsecops-app-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types   = [var.instance_type]
  
  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  
}