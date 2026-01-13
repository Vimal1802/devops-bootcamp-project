# 1. EXTERNAL-FACING SECURITY POLICY
# Manages public access for the web application and facilitates secure cross-tier monitoring.
resource "aws_security_group" "public_sg" {
  name        = "devops-public-sg"
  description = "Public Web and Internal Scraping"
  vpc_id      = aws_vpc.devops_vpc.id

  # Enables global HTTP access to the application layer.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Standard outbound configuration to allow resource updates and external API communication.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-public-sg" }
}

# Authorizes specific telemetry traffic from the Private Monitoring Tier to the Public Application Tier.
resource "aws_security_group_rule" "allow_prometheus_scraping" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  description              = "Prometheus scraping from monitoring server"
  security_group_id        = aws_security_group.public_sg.id
  source_security_group_id = aws_security_group.private_sg.id
}

# 2. INTERNAL MANAGEMENT & MONITORING SECURITY POLICY
# Isolates administrative and monitoring services while maintaining required connectivity for management tools.
resource "aws_security_group" "private_sg" {
  name        = "devops-private-sg"
  description = "Internal Management - No Inbound Ports Needed"
  vpc_id      = aws_vpc.devops_vpc.id

  # Permits unrestricted internal traffic between private management and monitoring resources.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Facilitates secure inbound communication from the Public Tier for log and metric collection.
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_sg.id]
  }

  # Authorizes essential outbound traffic for SSM management, ECR image retrieval, and Cloudflare tunneling.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-private-sg" }
}
