resource "aws_secretsmanager_secret" "db_password" {
  name = "db_password"
  tags = var.team_tags
}

resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.master
}