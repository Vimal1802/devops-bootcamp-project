# 1. GITHUB OIDC FEDERATION
# Configures a secure OpenID Connect (OIDC) trust relationship to allow GitHub Actions to authenticate without long-lived AWS credentials.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] 
}

# 2. CI/CD EXECUTION ROLE
# Defines the identity used by GitHub Actions, restricted specifically to the 'devops-bootcamp-project' repository.
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
          "token.actions.githubusercontent.com:sub": "repo:Vimal1802/devops-bootcamp-project:*"
        }
      }
    }]
  })
}

# 3. PIPELINE PERMISSIONS (Least Privilege)
resource "aws_iam_role_policy" "github_combined_policy" {
  name = "github-actions-policy"
  role = aws_iam_role.github_oidc_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRPushAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*" 
      },
      {
        Sid      = "SSM Access"
        Effect   = "Allow"
        Action   = ["ssm:SendCommand","ssm:GetCommandInvocation"]
        Resource = [
          "arn:aws:ec2:*:*:instance/*", 
          "arn:aws:ssm:*:*:document/AWS-RunShellScript",
          "arn:aws:ssm:*:*:*"
        ]
      }
    ]
  })
}

# 4. ANSIBLE ORCHESTRATION ROLE
# Empowers the Ansible Controller to discover VPC resources, manage SSM sessions, and handle artifact transit via S3.
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
        Sid    = "S3AnsibleShuttle"
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:ListBucket", "s3:GetObject", "s3:DeleteObject", "s3:GetBucketLocation"]
        Resource = ["arn:aws:s3:::devops-bootcamp-terraform-vimaldeep", "arn:aws:s3:::devops-bootcamp-terraform-vimaldeep/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ansible_ssm" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 5. MANAGED WORKLOAD ROLE
# Grants application nodes the necessary permissions to retrieve container images and maintain connectivity with Systems Manager.
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
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 6. INSTANCE RUNTIME PROFILES
# Attaches the defined IAM roles to EC2 instances to enable secure, credential-less AWS service interaction.
resource "aws_iam_instance_profile" "ansible_profile" {
  name = "ansible-profile"
  role = aws_iam_role.ansible_role.name
}

resource "aws_iam_instance_profile" "node_profile" {
  name = "node-profile"
  role = aws_iam_role.managed_node_role.name
}
