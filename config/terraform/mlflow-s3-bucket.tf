resource "aws_s3_bucket" "ml_flow_s3_artifact_backend" {
  bucket = "ml_flow_s3_artifact_backend-mlops"
  acl    = "private"
  tags   = var.team_tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.mlflow_s3_kms_key.id
      }
    }
  }
}

data "aws_iam_policy_document" "mlflow-s3-artifact-bucket-policy" {
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
    aws_s3_bucket.ml_flow_s3_artifact_backend.arn]
    condition {
      test     = "NotIpAddress"
      values   = [var.platform_vpc_id]
      variable = "aws:SourceVpc"
    }
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
    aws_s3_bucket.ml_flow_s3_artifact_backend.arn]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
    aws_s3_bucket.ml_flow_s3_artifact_backend.arn]
    condition {
      test     = "ArnEquals"
      values   = [aws_iam_role.mlflow_fargate_task_execution_role.arn]
      variable = "aws:SourceArn"
    }
  }
  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
    aws_s3_bucket.ml_flow_s3_artifact_backend.arn]
    condition {
      test     = "ArnNotEquals"
      values   = [aws_iam_role.mlflow_fargate_task_execution_role.arn]
      variable = "aws:SourceArn"
    }
  }
}
