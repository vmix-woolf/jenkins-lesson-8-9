variable "github_ssh_private_key" {
  description = "SSH private key for GitHub repository access"
  type        = string
  sensitive   = true
}