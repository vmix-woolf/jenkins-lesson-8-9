output "endpoint" {
  description = "Database endpoint address."
  value = var.use_aurora ? (
    aws_rds_cluster.this[0].endpoint
    ) : (
    aws_db_instance.this[0].address
  )
}

output "reader_endpoint" {
  description = "Aurora reader endpoint. Null for regular RDS."
  value       = var.use_aurora ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "port" {
  description = "Database port."
  value       = local.selected_port
}

output "db_identifier" {
  description = "Database instance or cluster identifier."
  value = var.use_aurora ? (
    aws_rds_cluster.this[0].cluster_identifier
    ) : (
    aws_db_instance.this[0].identifier
  )
}

output "security_group_id" {
  description = "Database security group ID."
  value       = aws_security_group.this.id
}

output "subnet_group_name" {
  description = "Database subnet group name."
  value       = aws_db_subnet_group.this.name
}

output "parameter_group_name" {
  description = "Parameter group name used by selected database mode."
  value = var.use_aurora ? (
    aws_rds_cluster_parameter_group.this.name
    ) : (
    aws_db_parameter_group.this.name
  )
}