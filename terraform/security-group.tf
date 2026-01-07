# 1. Web Server Security Group
resource "aws_security_group" "public_sg" {
  name        = "devops-public-sg"
  description = "Public Web and Internal Scraping"
  vpc_id      = aws_vpc.devops_vpc.id

  # Public Access for the App
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-public-sg" }
}

resource "aws_security_group_rule" "allow_prometheus_scraping" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  description              = "Prometheus scraping from monitoring server"
  
  # Which group is RECEIVING the traffic?
  security_group_id        = aws_security_group.public_sg.id
  
  # Which group is SENDING the traffic?
  source_security_group_id = aws_security_group.private_sg.id
}

# 2. Ansible Controller & Monitoring Security Group
resource "aws_security_group" "private_sg" {
  name        = "devops-private-sg"
  description = "Internal Management - No Inbound Ports Needed"
  vpc_id      = aws_vpc.devops_vpc.id

  # Allow all internal traffic within this SG (Controller <-> Monitor)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow the Web Server SG to talk back if needed (e.g., push metrics)
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_sg.id]
  }

  # Outbound REQUIRED: For SSM, ECR, and Cloudflare Tunneling
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "devops-private-sg" }
}