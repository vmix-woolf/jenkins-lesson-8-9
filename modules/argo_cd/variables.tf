variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
}

variable "service_type" {
  description = "Kubernetes service type for Argo CD server"
  type        = string
  default     = "LoadBalancer"
}

variable "repository_url" {
  description = "Git repository URL for Argo CD"
  type        = string
}

variable "repository_private_key" {
  description = "SSH private key for Argo CD repository access"
  type        = string
  sensitive   = true
}

variable "target_revision" {
  description = "Git branch watched by Argo CD"
  type        = string
  default     = "main"
}

variable "app_chart_path" {
  description = "Path to Helm chart in Git repository"
  type        = string
  default     = "charts/django-app"
}

variable "app_namespace" {
  description = "Namespace for Django application"
  type        = string
  default     = "django-app"
}