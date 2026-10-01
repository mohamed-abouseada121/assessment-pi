resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                   = "${var.project_name}-${var.environment}-postgres"
  engine                       = "postgres"
  engine_version               = "16.9"
  instance_class               = var.instance_class
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = 20
  storage_type                 = "gp2"
  storage_encrypted            = true
  multi_az                     = false
  publicly_accessible          = false
  auto_minor_version_upgrade   = true
  backup_retention_period      = 1
  performance_insights_enabled = false
  skip_final_snapshot          = true
  deletion_protection          = false
  db_name                      = var.db_name
  username                     = var.db_username
  password                     = var.db_password
  port                         = 5432
  vpc_security_group_ids       = [var.rds_security_group_id]
  db_subnet_group_name         = aws_db_subnet_group.this.name

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-postgres"
  })
}
