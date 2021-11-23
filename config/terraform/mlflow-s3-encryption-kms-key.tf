resource "aws_kms_key" "mlflow_s3_kms_key" {
  name = "mlflow-s3-kms-key"
  tags = var.team_tags

  key_usage  = "ENCRYPT_DECRYPT"
  is_enabled = true

  policy = data.aws_iam_policy_document.mlflow_s3_kms_policy_document.json

  enable_key_rotation     = false
  deletion_window_in_days = 30
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "mlflow_s3_kms_key_alias" {
  name          = "alias/${aws_kms_key.mlflow_s3_kms_key.name}"
  target_key_id = aws_kms_key.mlflow_s3_kms_key.key_id

  depends_on = [
    aws_kms_key.mlflow_s3_kms_key
  ]
}

data "aws_iam_policy_document" "mlflow_s3_kms_policy_document" {
  statement {
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:GenerateDataKey*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.mlflow_fargate_task_execution_role.arn]
    }
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }
}
