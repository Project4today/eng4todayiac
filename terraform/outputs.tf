output "app_env_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing application environment variables."
  value       = aws_secretsmanager_secret.app_env.arn
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for pushing container images."
  value       = aws_ecr_repository.main.repository_url
}
