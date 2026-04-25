# ── EKS Cluster (control plane) ───────────────────────────────────────────────
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn # IAM rol die de control plane toestemming geeft
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids         = var.subnet_ids         # subnets waar de control plane en nodes in draaien
    security_group_ids = var.security_group_ids # security group voor cluster communicatie
  }
}

# ── EKS Node Group (worker nodes) ────────────────────────────────────────────
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name  # impliciet depends_on — node group wacht op het cluster
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.node_role_arn          # IAM rol die de worker nodes toestemming geeft
  subnet_ids      = var.subnet_ids             # worker nodes draaien in private subnets
  instance_types  = [var.instance_type]
  ami_type        = "AL2_x86_64" # expliciet Amazon Linux 2 AMI opgeven om versie-conflicten te vermijden

  scaling_config {
    desired_size = var.desired_size # normaal gewenst aantal nodes
    min_size     = var.min_size     # minimaal bij downscaling
    max_size     = var.max_size     # maximaal bij upscaling
  }
}
