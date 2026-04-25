
module "VPC" {
  source = "./modules/VPC"

  vpc_cidr            = "10.0.0.0/16"
  private_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"] # twee private subnets, één per AZ
  public_subnet_cidr  = ["10.0.3.0/24", "10.0.4.0/24"] # twee public subnets, één per AZ
  subnet_az           = "us-east-1a"                    # eerste AZ
  subnet_az2          = "us-east-1b"                    # tweede AZ verplicht voor eks
  vpc_name            = "devsecops-vpc"
  subnet_name         = "devsecops-subnet"
  igw_name            = "devsecops-igw"
  rt_name             = "devsecops-rt"
}


module "IAM" {
  source = "./modules/IAM"

  cluster_name = "devsecops-eks-cluster" # wordt gebruikt als prefix voor de IAM rol namen
}


module "SecurityGroup" {
  source = "./modules/SecurityGroup"

  vpc_id         = module.VPC.vpc_id  # referentie via module output, niet direct aan de resource
  vpc_cidr       = "10.0.0.0/16"     # zelfde CIDR als de VPC, voor ingress regels
  sg_name        = "devsecops-sg"
  sg_description = "Security group voor het EKS cluster"
}

module "EKS" {
  source = "./modules/EKS"

  cluster_name       = module.IAM.cluster_name      # cluster naam komt uit IAM module
  cluster_role_arn   = module.IAM.cluster_role_arn  # ARN van de control plane rol
  node_role_arn      = module.IAM.node_role_arn     # ARN van de worker node rol
  subnet_ids         = [                            # worker nodes alleen in private subnets
    module.VPC.private_subnet1_id,
    module.VPC.private_subnet2_id,
  ]
  security_group_ids = [module.SecurityGroup.sg_id] # security group voor cluster communicatie
  kubernetes_version = "1.29"                       # ondersteunde versie, 1.21 was end-of-life
  instance_type      = "t3.medium"
  desired_size       = 2
  min_size           = 1
  max_size           = 3

  depends_on = [module.IAM] # IAM policies moeten klaar zijn voordat EKS wordt aangemaakt
}

resource "aws_ecr_repository" "devsecops_repo" {
  name                 = "devsecops-repo-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # scant images automatisch op kwetsbaarheden bij elke push
  }
}
