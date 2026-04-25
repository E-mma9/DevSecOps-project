resource "aws_security_group" "main" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  # Staat verkeer toe tussen nodes onderling (node-to-node communicatie)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"          # alle protocollen
    self      = true          # alleen verkeer van andere resources met dezelfde security group
  }

  # Staat HTTPS toe vanuit de VPC — vereist voor communicatie met de EKS API server
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # alleen vanuit het eigen VPC netwerk, niet publiek internet
  }

  # Staat alle uitgaand verkeer toe — vereist voor het pullen van container images en AWS API calls
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # alle protocollen
    cidr_blocks = ["0.0.0.0/0"] # naar alle bestemmingen
  }

  tags = {
    Name = var.sg_name
  }
}
