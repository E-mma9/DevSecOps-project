resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({ # Trust policy for permissions (only access)
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # Allow EKS to assume this role
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com" # who gets the role (EKS service)
        }
      }
    ]
  })
  
}
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" # Gives EKS permission to do lifecyle networking etc...
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({ # Trust policy for permissions (only access)
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # Allow EC2 to assume this role for worker nodes
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # who gets the role (EC2 service for worker nodes)
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_role_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" # Permissions for worker nodes to join cluster
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # Permissions for networking (CNI plugin)
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # Permissions for pulling container images from ECR
}

