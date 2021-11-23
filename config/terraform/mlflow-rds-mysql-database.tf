locals {
  database_subnet_group_name = "dbsgusameaprivate"
}

module "rds-aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "5.2.0"

  name                            = "mlflow_backend_store_db"
  database_name                   = "mlflowbackend"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.26"
  instance_type                   = "db.t3.small"
  instance_type_replica           = "db.t3.small"
  db_cluster_parameter_group_name = "default"
  db_parameter_group_name         = "default"
  enabled_cloudwatch_logs_exports = ["mysql"]

  replica_count         = 1
  replica_scale_enabled = true
  replica_scale_min     = 1
  replica_scale_max     = 5

  monitoring_interval    = 60
  create_monitoring_role = true

  apply_immediately   = true
  skip_final_snapshot = true
  deletion_protection = true
  publicly_accessible = false

  allowed_security_groups = ["sg-09f82175e1ae28431"]
  storage_encrypted       = true

  vpc_id                = var.platform_vpc_id
  db_subnet_group_name  = local.database_subnet_group_name
  create_security_group = true
  tags                  = var.team_tags

  username = var.db_username
  password = aws_secretsmanager_secret_version.password
}

# aws_rds_cluster
output "rds_cluster_id" {
  description = "The ID of the cluster"
  value       = module.rds-aurora.rds_cluster_id
}

output "rds_cluster_resource_id" {
  description = "The Resource ID of the cluster"
  value       = module.rds-aurora.rds_cluster_resource_id
}

output "rds_cluster_endpoint" {
  description = "The cluster endpoint"
  value       = module.rds-aurora.rds_cluster_endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = module.rds-aurora.rds_cluster_reader_endpoint
}

output "rds_cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = module.rds-aurora.rds_cluster_database_name
}

output "rds_cluster_master_password" {
  description = "The master password"
  value       = module.rds-aurora.rds_cluster_master_password
  sensitive   = true
}

output "rds_cluster_port" {
  description = "The port"
  value       = module.rds-aurora.rds_cluster_port
}

output "rds_cluster_master_username" {
  description = "The master username"
  value       = module.rds-aurora.rds_cluster_master_username
  sensitive   = true
}

# aws_rds_cluster_instance
output "rds_cluster_instance_endpoints" {
  description = "A list of all cluster instance endpoints"
  value       = module.rds-aurora.rds_cluster_instance_endpoints
}

output "rds_cluster_instance_ids" {
  description = "A list of all cluster instance ids"
  value       = module.rds-aurora.rds_cluster_instance_ids
}

# aws_security_group
output "security_group_id" {
  description = "The security group ID of the cluster"
  value       = module.rds-aurora.security_group_id
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  description = "The name of the enhanced monitoring role"
  value       = module.rds-aurora.enhanced_monitoring_iam_role_name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the enhanced monitoring role"
  value       = module.rds-aurora.enhanced_monitoring_iam_role_arn
}

output "enhanced_monitoring_iam_role_unique_id" {
  description = "Stable and unique string identifying the enhanced monitoring role"
  value       = module.rds-aurora.enhanced_monitoring_iam_role_unique_id
}
