# ── VPC ──────────────────────────────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true  # vereist zodat EKS nodes DNS namen kunnen oplossen
  enable_dns_hostnames = true  # vereist zodat EKS nodes een hostname krijgen

  tags = {
    Name = var.vpc_name
  }
}

# ── Private subnets (worker nodes) ───────────────────────────────────────────
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr[0] # eerste private CIDR uit de lijst
  availability_zone       = var.subnet_az              # eerste AZ
  map_public_ip_on_launch = false                      # private subnet — geen publiek IP

  tags = {
    Name = "${var.subnet_name}-private-1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr[1] # tweede private CIDR uit de lijst
  availability_zone       = var.subnet_az2             # tweede AZ — vereist door EKS
  map_public_ip_on_launch = false                      # private subnet — geen publiek IP

  tags = {
    Name = "${var.subnet_name}-private-2"
  }
}

# ── Public subnets (NAT gateway, load balancers) ─────────────────────────────
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr[0] # eerste public CIDR uit de lijst
  availability_zone       = var.subnet_az             # eerste AZ
  map_public_ip_on_launch = true                      # public subnet — krijgt automatisch een publiek IP

  tags = {
    Name = "${var.subnet_name}-public-1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr[1] # tweede public CIDR uit de lijst
  availability_zone       = var.subnet_az2            # tweede AZ
  map_public_ip_on_launch = true                      # public subnet — krijgt automatisch een publiek IP

  tags = {
    Name = "${var.subnet_name}-public-2"
  }
}

# ── Internet Gateway (public internettoegang) ─────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # koppelt de IGW aan de VPC

  tags = {
    Name = var.igw_name
  }
}

# ── Elastic IP voor de NAT Gateway ───────────────────────────────────────────
resource "aws_eip" "nat" {
  vpc = true # reserveert een publiek IP adres voor de NAT gateway

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# ── NAT Gateway (private subnets bereiken het internet) ──────────────────────
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id          # koppelt het gereserveerde publieke IP
  subnet_id     = aws_subnet.public_subnet1.id # NAT gateway staat in een public subnet

  tags = {
    Name = "${var.vpc_name}-nat"
  }

  depends_on = [aws_internet_gateway.main] # IGW moet bestaan voordat NAT gateway werkt
}

# ── Public route table (via Internet Gateway) ─────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                    # al het uitgaand verkeer
    gateway_id = aws_internet_gateway.main.id   # gaat via de internet gateway
  }

  tags = {
    Name = "${var.rt_name}-public"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet1.id # koppelt public subnet 1 aan de public route table
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet2.id # koppelt public subnet 2 aan de public route table
  route_table_id = aws_route_table.public.id
}

# ── Private route table (via NAT Gateway) ────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"                # al het uitgaand verkeer van worker nodes
    nat_gateway_id = aws_nat_gateway.main.id    # gaat via de NAT gateway (niet direct internet)
  }

  tags = {
    Name = "${var.rt_name}-private"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet1.id # koppelt private subnet 1 aan de private route table
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet2.id # koppelt private subnet 2 aan de private route table
  route_table_id = aws_route_table.private.id
}
