locals {
  is_postgres = contains(["postgres", "aurora-postgresql"], var.engine)
  is_mysql    = contains(["mysql", "aurora-mysql"], var.engine)

  selected_port = var.db_port != null ? var.db_port : (
    local.is_postgres ? 5432 : 3306
  )

  rds_parameter_group_family = (
    var.engine == "postgres" ? "postgres15" :
    var.engine == "mysql" ? "mysql8.0" :
    "postgres15"
  )

  aurora_parameter_group_family = (
    var.engine == "aurora-postgresql" ? "aurora-postgresql15" :
    var.engine == "aurora-mysql" ? "aurora-mysql8.0" :
    "aurora-postgresql15"
  )

  common_tags = merge(
    var.tags,
    {
      Module = "rds"
      Name   = var.name
    }
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.name}-db-sg"
  description = "Security group for database resources"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidr_blocks

    content {
      description = "Database access from CIDR"
      from_port   = local.selected_port
      to_port     = local.selected_port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_security_group_ids

    content {
      description     = "Database access from security group"
      from_port       = local.selected_port
      to_port         = local.selected_port
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-db-sg"
    }
  )
}

resource "aws_db_parameter_group" "this" {
  name        = "${var.name}-rds-parameter-group"
  family      = local.rds_parameter_group_family
  description = "Parameter group for regular RDS instance"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []

    content {
      name  = "log_statement"
      value = var.log_statement
    }
  }

  dynamic "parameter" {
    for_each = local.is_postgres ? [1] : []

    content {
      name  = "work_mem"
      value = var.work_mem
    }
  }

  tags = local.common_tags
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${var.name}-aurora-parameter-group"
  family      = local.aurora_parameter_group_family
  description = "Parameter group for Aurora cluster"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  dynamic "parameter" {
    for_each = var.engine == "aurora-postgresql" ? [1] : []

    content {
      name  = "log_statement"
      value = var.log_statement
    }
  }

  dynamic "parameter" {
    for_each = var.engine == "aurora-postgresql" ? [1] : []

    content {
      name  = "work_mem"
      value = var.work_mem
    }
  }

  tags = local.common_tags
}