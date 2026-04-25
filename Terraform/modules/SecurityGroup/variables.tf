variable "sg_name" {
  description = "Naam van de security group"
  type        = string
}

variable "sg_description" {
  description = "Beschrijving van de security group"
  type        = string
}

variable "vpc_id" {
  description = "ID van de VPC waar de security group in wordt aangemaakt"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR blok van de VPC — gebruikt voor ingress regels binnen het netwerk"
  type        = string
}
