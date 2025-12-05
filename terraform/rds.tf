resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "16.3" # Selecting a recent version supported by Free Tier
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password
  db_name           = "eng4today_db"

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false
  multi_az            = false # Explicitly Single AZ for Free Tier

  tags = {
    Name = "${var.project_name}-db"
  }
}
