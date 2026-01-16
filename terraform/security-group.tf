# 1. PUBLIC SECURITY GROUP (For the Web Server)
resource "aws_security_group" "public_sg" {
  name        = "devops-public-sg"
  description = "Security group for public-facing web server"
  vpc_id      = aws_vpc.main.id 

  # Port 80: Allow web traffic from anywhere in the world
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  # Port 9100: Allow Prometheus to scrape metrics 
  # This ONLY allows your Monitoring Server (10.0.0.136) to see the metrics
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.136/32"] 
    description = "Allow Prometheus scraping from Monitoring Server"
  }

  # Port 22: REMOVED. Management handled by AWS SSM.

  # Outbound: REQUIRED for SSM Agent to communicate with AWS
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. PRIVATE SECURITY GROUP (For Ansible Controller & Monitoring Server)
resource "aws_security_group" "private_sg" {
  name        = "devops-private-sg"
  description = "Security group for internal management and monitoring"
  vpc_id      = aws_vpc.main.id

  # Port 22: REMOVED. Management handled by AWS SSM.
  # Note: Since these servers are in a private subnet and have no public IP, 
  # having no ingress rules makes them extremely secure.

  # Outbound: Essential for Cloudflare Tunnel and SSM to connect out to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
