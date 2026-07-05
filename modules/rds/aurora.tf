resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier = "${var.name}-aurora"

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.database_name
  master_username = var.username
  master_password = var.password
  port            = local.selected_port

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  apply_immediately = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-aurora"
      Type = "aurora-cluster"
    }
  )
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier = "${var.name}-aurora-writer"

  cluster_identifier = aws_rds_cluster.this[0].id

  engine         = aws_rds_cluster.this[0].engine
  engine_version = aws_rds_cluster.this[0].engine_version
  instance_class = var.instance_class

  db_subnet_group_name = aws_db_subnet_group.this.name

  publicly_accessible = var.publicly_accessible

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-aurora-writer"
      Type = "aurora-writer"
    }
  )
}