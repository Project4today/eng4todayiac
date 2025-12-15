# ECR Repository
resource "aws_ecr_repository" "main" {
  name = var.project_name # This will resolve to "eng4today"

  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.project_name
  }
}
