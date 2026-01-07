# 1. VPC
resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/24"
  tags       = { Name = "devops-vpc" }
}

# 2. Subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.0.0/25"
  tags       = { Name = "devops-public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.0.128/25"
  tags       = { Name = "devops-private-subnet" }
}

# 3. Route Tables
# ADOPT the Default Route Table (Use this for Public)
# This prevents a 3rd table from being created.
resource "aws_default_route_table" "public_route" {
  default_route_table_id = aws_vpc.devops_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "devops-public-route" }
}

# Create only ONE new Route Table (For Private)
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = { Name = "devops-private-route" }
}

# 4. Gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
}

# 6. Associations
# Note: You don't strictly need to associate the public subnet 
# because it's now using the "Default" table, but it's good practice.
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_default_route_table.public_route.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route.id
}