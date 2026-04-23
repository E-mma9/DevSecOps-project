resource "aws_security_group" "main" {
    name = var.sg_name
    description = var.sg_description
    vpc_id = var.vpc_id
    tags = {
        Name = var.sg_name
    }
  
}

resource "ingress" "n" {
  
}
