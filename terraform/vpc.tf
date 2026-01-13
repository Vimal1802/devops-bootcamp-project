# 1. PRIMARY NETWORK TOPOLOGY
# Establishes the foundational Virtual Private Cloud (VPC) to provide an isolated and secure network environment.
resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/24"
  tags       = { Name = "devops-vpc" }
}

# 2. NETWORK SEGMENTATION (SUBNETS)
# Provisions a Public Tier for external-facing resources (Gateways/Load Balancers).
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.0.0/25"
  tags       = { Name = "devops-public-subnet" }
}

# Provisions a Private Tier for secure backend workloads, isolating them from direct internet exposure.
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.0.128/25"
  tags       = { Name = "devops-private-subnet" }
}

# 3. TRAFFIC ROUTING POLICIES
# Adopts the VPC's default routing table for the Public Tier to manage public traffic flow, ensuring efficient resource management.
resource "aws_default_route_table" "public_route" {
  default_route_table_id = aws_vpc.devops_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "devops-public-route" }
}

# Configures a dedicated routing table for the Private Tier to direct outbound traffic through the NAT Gateway.
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = { Name = "devops-private-route" }
}

# 4. CONNECTIVITY GATEWAYS
# Enables bidirectional internet communication for resources within the Public Tier.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id
}

# Reserves a Static Elastic IP (EIP) for the NAT Gateway to establish a persistent and recognizable outbound identity for all traffic originating from the Private Tier.
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Provisions a NAT Gateway with a static EIP in the public subnet to provide secure, outbound-only internet access for private tier resources.
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id      = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
}

# 5. SUBNET-TO-ROUTE ASSOCIATIONS
# Explicitly links subnets to their respective routing tables to enforce network isolation and traffic rules.
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_default_route_table.public_route.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route.id
}
