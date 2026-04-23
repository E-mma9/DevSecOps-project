variable "vpc_cidr" { 
    description = "The CIDR block for the VPC"
    type        = string
  
}

variable "subnet_cidr" {
    description = "The CIDR block for the subnet"
    type        = string
  
}

variable "subnet_az" {
    description = "The availability zone for the subnet"
    type        = string
  
}

variable "vpc_name" {
    description = "The name of the VPC"
    type        = string
  
}

variable "subnet_name" {
    description = "The name of the subnet"
    type        = string
  
}

variable "igw_name" {
    description = "The name of the internet gateway"
    type        = string
  
}

variable "rt_name" {
    description = "The name of the route table"
    type        = string
  
}

