# Secret for Application Environment Variables
resource "aws_secretsmanager_secret" "app_env" {
  # Use a deterministic name for stability and easier referencing.
  name = "${var.project_name}/${var.environment}/app-env-01"

  # For non-production, delete immediately. For production, use a value like 7 or 30.
  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Version for the Application Environment Variables Secret
resource "aws_secretsmanager_secret_version" "app_env_version" {
  secret_id = aws_secretsmanager_secret.app_env.id
  secret_string = jsonencode({
    # Database connection details
    DB_HOST     = aws_db_instance.main.address
    DB_PORT     = aws_db_instance.main.port
    DB_NAME     = aws_db_instance.main.db_name
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password

    # Other application-specific environment variables can be added here
  })

  # This lifecycle block prevents Terraform from overwriting the secret 
  # if it's updated manually in the AWS console.
  lifecycle {
    ignore_changes = [secret_string]
  }

  # Explicitly state that this resource depends on the RDS instance being available.
  depends_on = [aws_db_instance.main]
}
