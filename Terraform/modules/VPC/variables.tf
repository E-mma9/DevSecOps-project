variable "vpc_cidr" {
  description = "CIDR blok voor de VPC"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Lijst van CIDR blokken voor de private subnets"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "Lijst van CIDR blokken voor de public subnets"
  type        = list(string)
}

variable "subnet_az" {
  description = "Eerste availability zone voor de subnets"
  type        = string
}

variable "subnet_az2" {
  description = "Tweede availability zone voor de subnets — EKS vereist minimaal 2 AZs"
  type        = string
}

variable "vpc_name" {
  description = "Naam van de VPC"
  type        = string
}

variable "subnet_name" {
  description = "Prefix voor de subnet namen"
  type        = string
}

variable "igw_name" {
  description = "Naam van de internet gateway"
  type        = string
}

variable "rt_name" {
  description = "Prefix voor de route table namen"
  type        = string
}
