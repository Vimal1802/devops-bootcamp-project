# 1. Lookup Ubuntu 24.04 AMI
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 2. Server 1 - Web Server (Public Subnet)
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  private_ip             = "10.0.0.5"
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  
  # LINKED TO NODE PROFILE
  iam_instance_profile   = aws_iam_instance_profile.node_profile.name 

  tags = { Name = "Web Server" }
}

resource "aws_eip" "web_eip" {
  instance = aws_instance.web_server.id
  domain   = "vpc"
  tags     = { Name = "Web Server-EIP" }
}

# 3. Server 2 - Ansible Controller (Private Subnet)
resource "aws_instance" "ansible_controller" {
  ami                         = data.aws_ami.ubuntu_24_04.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  private_ip                  = "10.0.0.135"
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  
  # LINKED TO ANSIBLE PROFILE
  iam_instance_profile        = aws_iam_instance_profile.ansible_profile.name
  associate_public_ip_address = false

user_data = <<-EOF
    #!/bin/bash
    exec > /home/ubuntu/deploy.log 2>&1

    # Fast network check
    timeout 60s bash -c 'until ping -c 1 google.com; do sleep 2; done'

    # Install prerequisites
    apt-get update -y
    apt-get install -y unzip pipx python3-venv

    # Official AWS CLI v2 Installation
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip -d /tmp/
    /tmp/aws/install

    # Session Manager Plugin
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/ssm.deb"
    dpkg -i /tmp/ssm.deb

    # Consolidated Ansible & pipx setup
    sudo -H -u ubuntu bash -c '
      pipx install --include-deps ansible
      pipx inject ansible boto3 botocore
      pipx ensurepath
    '
    
    # Deploy Ansible project files
    mkdir -p /home/ubuntu/ansible
    echo '${local.ansible_zip_data}' | base64 -d > /tmp/ansible.zip
    unzip -o /tmp/ansible.zip -d /home/ubuntu/ansible
    chown -R ubuntu:ubuntu /home/ubuntu/ansible
    
    echo "Ansible Controller Setup Complete."
  EOF

  tags = { Name = "Ansible Controller" }
  depends_on = [data.archive_file.ansible_pack]
}

# 4. Server 3 - Monitoring Server (Private Subnet)
resource "aws_instance" "monitoring_server" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  private_ip             = "10.0.0.136"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  
  # LINKED TO NODE PROFILE
  iam_instance_profile   = aws_iam_instance_profile.node_profile.name 

  associate_public_ip_address = false
  tags = { Name = "Monitoring Server" }
}

# --- Outputs ---
output "web_server_id" {
  value = aws_instance.web_server.id
}

output "monitoring_server_id" {
  value = aws_instance.monitoring_server.id
}

output "ansible_controller_id" {
  value = aws_instance.ansible_controller.id
}
