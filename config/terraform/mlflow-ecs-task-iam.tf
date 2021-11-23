data "aws_iam_policy_document" "mlflow-ecs-tasks-trust-assumerole-policy" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mlflow_fargate_task_execution_role" {
  name                  = "mlflow_fargate_task_execution_role"
  force_detach_policies = true
  tags                  = var.team_tags

  assume_role_policy = data.aws_iam_policy_document.mlflow-ecs-tasks-trust-assumerole-policy.json

  managed_policy_arns = [
    aws_iam_policy.ecs_allow_s3_actions.arn,
    aws_iam_policy.ecs_allow_secrets_actions.arn,
    aws_iam_policy.ecs_allow_ecs_actions.arn
  ]
}

resource "aws_iam_policy" "ecs_allow_s3_actions" {
  name = "ecs_allow_s3_actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:GetBucketCors",
        "s3:PutBucketCors"
      ]
      Effect   = "Allow"
      Resource = "*"
  }] })
}

# this policy allows secrets manager related permissions to ecs task execution role
resource "aws_iam_policy" "ecs_allow_secrets_actions" {
  name = "ecs_allow_secrets_actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetRandomPassword",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:UntagResource",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecrets",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:TagResource",

      ]
      Resource = ["*"]
      Effect   = "Allow"
      Condition = {
        test     = "StringLike"
        variable = "aws:ResourceTag/ApplicationName"
        values   = ["${var.team_tags.AppName}"]
      }
    }]
  })
}

# this policy allows secrets manager related permissions to ecs task execution role
resource "aws_iam_policy" "ecs_allow_ecs_actions" {
  name = "ecs_allow_ecs_actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      actions = [
        "ecs:*",
        "ec2:*",
        "cloudwatch:*",
        "application-autoscaling:*",
        "autoscaling:*",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfiles",
        "iam:ListRoles",
        "lambda:ListFunctions",
        "logs:CreateLogGroup",
        "logs:DescribeLogGroups",
        "logs:FilterLogEvents",
        "servicediscovery:CreatePrivateDnsNamespace",
        "servicediscovery:CreateService",
        "servicediscovery:DeleteService",
        "servicediscovery:GetNamespace",
        "servicediscovery:GetOperation",
        "servicediscovery:GetService",
        "servicediscovery:ListNamespaces",
        "servicediscovery:ListServices",
        "servicediscovery:UpdateService",
        "sns:ListTopics"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]

  })
}
