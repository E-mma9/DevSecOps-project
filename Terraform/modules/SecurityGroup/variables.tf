variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "sg_description" {
  description = "A description of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

