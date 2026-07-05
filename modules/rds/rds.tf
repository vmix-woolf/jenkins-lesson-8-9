resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.name}-rds"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.username
  password = var.password
  port     = local.selected_port

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  apply_immediately = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-rds"
      Type = "rds-instance"
    }
  )
}