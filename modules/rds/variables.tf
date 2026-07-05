variable "name" {
  description = "Base name for RDS resources."
  type        = string
  default     = "lesson-db"
}

variable "use_aurora" {
  description = "If true, creates an Aurora cluster. If false, creates a regular RDS instance."
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine. Supported values: postgres, mysql, aurora-postgresql, aurora-mysql."
  type        = string
  default     = "postgres"

  validation {
    condition = contains([
      "postgres",
      "mysql",
      "aurora-postgresql",
      "aurora-mysql"
    ], var.engine)
    error_message = "Engine must be one of: postgres, mysql, aurora-postgresql, aurora-mysql."
  }
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Database instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master database username."
  type        = string
  default     = "dbadmin"
}

variable "password" {
  description = "Master database password."
  type        = string
  sensitive   = true
  default     = "ChangeMe123456!"
}

variable "vpc_id" {
  description = "VPC ID where database resources will be created."
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for DB subnet group."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the database."
  type        = list(string)
  default     = []
}

variable "db_port" {
  description = "Database port. If null, port is selected automatically by engine."
  type        = number
  default     = null
}

variable "allocated_storage" {
  description = "Allocated storage size in GB for regular RDS instance."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type for regular RDS instance."
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ for regular RDS instance."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting database resources."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether regular RDS instance should be publicly accessible."
  type        = bool
  default     = false
}

variable "max_connections" {
  description = "Value for max_connections parameter."
  type        = string
  default     = "100"
}

variable "log_statement" {
  description = "Value for log_statement parameter."
  type        = string
  default     = "none"
}

variable "work_mem" {
  description = "Value for PostgreSQL work_mem parameter."
  type        = string
  default     = "4096"
}

variable "tags" {
  description = "Common tags for all database resources."
  type        = map(string)
  default     = {}
}