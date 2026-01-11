# 1. Trust Relationship for the GitHub Repo
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 
}

# 2. GitHub OIDC Role
resource "aws_iam_role" "github_oidc_role" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Condition = {
        StringLike = {
          # UPDATED: Matches the specific repository you provided
          "token.actions.githubusercontent.com:sub": "repo:Vimal1802/devops-bootcamp-project:*"
        }
      }
    }]
  })
}

# 3. GitHub Permissions: ECR Access + SSM Command to Controller
resource "aws_iam_role_policy" "github_combined_policy" {
  name = "github-actions-policy"
  role = aws_iam_role.github_oidc_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAndSSM"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ssm:SendCommand"
        ]
        Resource = "*"
      }
    ]
  })
}

# 4. ANSIBLE CONTROLLER ROLE (The Scout)
resource "aws_iam_role" "ansible_role" {
  name = "ansible-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "ansible_core_logic" {
  name = "ansible-logic"
  role = aws_iam_role.ansible_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "InventoryDiscovery"
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:DescribeTags", "ec2:DescribeRegions"]
        Resource = "*"
      },
      {
        Sid      = "SSMConnectivity"
        Effect   = "Allow"
        Action   = ["ssm:DescribeInstanceInformation","ssm:StartSession", "ssm:SendCommand", "ssm:ListCommands","ssm:ListCommandInvocations"]
        Resource = "*"
      },
      {
        Sid    = "S3AnsibleShuttle" # THE MISSING PIECE
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ]
        "Resource": [
        "arn:aws:s3:::devops-bootcamp-terraform-vimaldeep",
        "arn:aws:s3:::devops-bootcamp-terraform-vimaldeep/*"
    ]
      }
    ]
  })
}

# Attach standard SSM Core
resource "aws_iam_role_policy_attachment" "ansible_ssm" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 5. MANAGED NODE ROLE (Web & Monitoring Servers)
resource "aws_iam_role" "managed_node_role" {
  name = "bootcamp-managed-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "node_ssm" {
  role       = aws_iam_role.managed_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.managed_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# 6. Instance Profiles
resource "aws_iam_instance_profile" "ansible_profile" {
  name = "ansible-profile"
  role = aws_iam_role.ansible_role.name
}

resource "aws_iam_instance_profile" "node_profile" {
  name = "node-profile"
  role = aws_iam_role.managed_node_role.name
}
