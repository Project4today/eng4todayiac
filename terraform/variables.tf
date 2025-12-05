variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used for naming resources"
  type        = string
  default     = "eng4todaycore"
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
  default     = "prod"
}

variable "container_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8000
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "postgres"
}
