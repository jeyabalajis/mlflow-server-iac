resource "aws_iam_role" "sagemaker-nbi-execution-role" {
  name                = "sagemaker-nbi-execution-role"
  assume_role_policy  = data.aws_iam_policy_document.sm-nbi-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.allow_s3_actions.arn]
}

data "aws_iam_policy_document" "sm-nbi-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "allow_s3_actions" {
  name = "policy-618033"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:CreateBucket",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:GetBucketCors",
          "s3:PutBucketCors"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_security_group" "sm_notebook_instance_sg" {
  name        = "sm_notebook_instance_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.platform_vpc_id

  tags = var.team_tags
}

resource "aws_security_group_rule" "sm_notebook_instance_sg_ingress_443" {
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.sm_notebook_instance_sg.id
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

resource "aws_security_group_rule" "edge-sg-egress-ldaps-3269" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sm_notebook_instance_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_sagemaker_notebook_instance" "smnbi_test" {
  name                   = "my-notebook-instance-test"
  role_arn               = aws_iam_role.sagemaker-nbi-execution-role.arn
  instance_type          = "ml.t2.medium"
  root_access            = "Disabled"
  direct_internet_access = "Disabled"
  subnet_id              = var.platform_private_subnet_ids[0]
  security_groups        = [aws_security_group.sm_notebook_instance_sg.id]

  tags = var.team_tags
}

output "notebook_instance_url" {
  description = "Notebook Instance URL"
  value       = aws_sagemaker_notebook_instance.smnbi_test.url
  sensitive   = false
}
