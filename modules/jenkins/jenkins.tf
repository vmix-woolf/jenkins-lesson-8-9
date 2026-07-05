resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "jenkins_admin" {
  metadata {
    name      = "jenkins-admin"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  type = "Opaque"

  data = {
    jenkins-admin-user     = var.admin_user
    jenkins-admin-password = var.admin_password
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name
  timeout    = 900
  wait       = true

  values = [
    templatefile("${path.module}/values.yaml", {
      admin_secret_name = kubernetes_secret.jenkins_admin.metadata[0].name
      service_type      = var.service_type
      storage_class     = var.storage_class
      storage_size      = var.storage_size
      jenkins_url       = var.jenkins_url
      ecr_repository    = var.ecr_repository
      aws_region        = var.aws_region
    })
  ]

  depends_on = [
    kubernetes_secret.jenkins_admin
  ]
}