module "VPC" {
    source = "./modules/VPC"
    vpc_cidr = "10.0.0.0/16"
    private_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
    subnet_az = "us-east-1a"
    vpc_name = "devsecops-vpc"
    subnet_name = "devsecops-subnet"
    igw_name = "devsecops-igw"
    rt_name = "devsecops-rt"
}
module "EKS" {
    source = "./modules/EKS"
    cluster_name = module.IAM.cluster_name
    cluster_role_arn = module.IAM.cluster_role_arn
    node_role_arn = module.IAM.node_role_arn
    subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id, aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
    kubernetes_version = "1.21"
    instance_type = "t3.medium"
    desired_size = 2
    min_size = 1
    max_size = 3
  
}

module "SecurityGroup" {
    source = "./modules/SecurityGroup"
    vpc_id = aws_vpc.main.id
    sg_name = "devsecops-sg"
    sg_description = "Security group for EKS cluster"
}   


module "IAM" {
    source = "./modules/IAM"
    cluster_name = "devsecops-eks-cluster"
    node_role_arn = aws_iam_role.node_role.arn
    cluster_role_arn = aws_iam_role.cluster_role.arn
  
}

resource "aws_ecr_repository" "DevSecOps-RepoEcr" {
    name = "devsecops-repo-ecr"
    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
        scan_on_push = true # first part of sec within DevSecOps, ensuring that images are scanned for vulnerabilities when they are pushed to the repository.
    }

  
}