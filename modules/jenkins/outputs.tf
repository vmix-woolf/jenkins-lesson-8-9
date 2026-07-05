output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "admin_user" {
  description = "Jenkins admin username"
  value       = var.admin_user
}

output "admin_password" {
  description = "Jenkins admin password"
  value       = var.admin_password
  sensitive   = true
}