resource "aws_cloudwatch_log_group" "mlflow_ecs_task_cw_log_group" {
  name = "/ecs/mlflow_ecs_task_cw_log_group"
  tags = var.team_tags
}

resource "aws_ecs_cluster" "mlflow_fargate_cluster" {
  name = "mlflow_fargate_cluster"

  tags = var.team_tags

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

}

resource "aws_ecs_task_definition" "mlflow_fargate_task" {
  family = aws_ecs_cluster.mlflow_fargate_cluster.name
  tags   = var.team_tags

  execution_role_arn = aws_iam_role.mlflow_fargate_task_execution_role.arn
  memory             = var.ecs_task_default_memory
  cpu                = var.ecs_task_default_cpu

  container_definitions = templatefile("./mlflow/containerDefs.json", {
    MLFLOW_DOCKER_IMAGE   = "docker.binrepo.cglcloud.in/mlops-mlflow-base-image:1.0.6"
    CLOUD_WATCH_LOG_GROUP = aws_cloudwatch_log_group.mlflow_ecs_task_cw_log_group.name
    BUCKET                = aws_s3_bucket.ml_flow_s3_artifact_backend.bucket_domain_name
    USERNAME              = module.rds-aurora.user_name
    HOST                  = module.rds-aurora.host
    PORT                  = var.mysql_default_port
    DATABASE              = module.rds-aurora.database_name
    PASSWORD              = aws_secretsmanager_secret_version.password.arn
  })
}

resource "aws_ecs_service" "mlflow-fargate-service" {
  name = "mlflow-fargate-service"
  tags = var.team_tags

  cluster = aws_ecs_cluster.mlflow_fargate_cluster.id

}
