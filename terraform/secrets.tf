resource "aws_secretsmanager_secret" "app_env" {
  name        = "${var.project_name}-env-vars"
  description = "Environment variables for the application"
}

# We create a placeholder version so the secret exists and has a value,
# preventing ECS from failing if it tries to fetch an empty secret.
resource "aws_secretsmanager_secret_version" "app_env_initial" {
  secret_id     = aws_secretsmanager_secret.app_env.id
  secret_string = jsonencode({
    DB_HOST = aws_db_instance.main.address
    DB_PORT = "5432"
    DB_USER = var.db_username
    DB_PASS = var.db_password
    DB_NAME = "eng4today_db"
  })
}
