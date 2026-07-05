output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state files"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_url" {
  description = "S3 URL of the Terraform state bucket"
  value       = "s3://${aws_s3_bucket.terraform_state.bucket}"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}