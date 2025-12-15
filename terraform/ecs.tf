locals {
  container_name = "${var.project_name}-container"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE_SPOT"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.project_name}"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = "${aws_ecr_repository.main.repository_url}:${var.image_tag}"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      secrets = [
        {
          name      = "DB_HOST"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:DB_HOST::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:DB_PORT::"
        },
        {
          name      = "DB_NAME"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:DB_NAME::"
        },
        {
          name      = "DB_USER"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:DB_USER::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:DB_PASSWORD::"
        },
        {
          name      = "GEMINI_API_KEY"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:GEMINI_API_KEY::"
        },
        {
          name      = "GEMINI_MODEL_VERSION"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:GEMINI_MODEL_VERSION::"
        },
        {
          name      = "AWS_ACCESS_KEY_ID"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:AWS_ACCESS_KEY_ID::"
        },
        {
          name      = "AWS_SECRET_ACCESS_KEY"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:AWS_SECRET_ACCESS_KEY::"
        },
        {
          name      = "S3_BUCKET_NAME"
          valueFrom = "${aws_secretsmanager_secret.app_env.arn}:S3_BUCKET_NAME::"
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Corrected network configuration
  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Use PUBLIC subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true                                           # MUST be true for internet access without a NAT Gateway
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  # This ensures the service waits for the ALB to be ready
  depends_on = [aws_lb_listener.http]
}
