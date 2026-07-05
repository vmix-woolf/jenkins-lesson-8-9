resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "django_app" {
  metadata {
    name = var.app_namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  timeout    = 900
  wait       = true

  values = [
    templatefile("${path.module}/values.yaml", {
      service_type = var.service_type
    })
  ]
}

resource "helm_release" "argocd_applications" {
  name      = "argocd-applications"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace.argocd.metadata[0].name
  timeout   = 300
  wait      = true

  values = [
    yamlencode({
      repository = {
        url           = var.repository_url
        sshPrivateKey = var.repository_private_key
      }

      application = {
        name           = "django-app"
        namespace      = var.namespace
        project        = "default"
        sourceRepoURL  = var.repository_url
        targetRevision = var.target_revision
        chartPath      = var.app_chart_path
        destination    = "https://kubernetes.default.svc"
        destNamespace  = var.app_namespace
      }
    })
  ]

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.django_app,
    kubernetes_secret.github_repository
  ]
}

resource "kubernetes_secret" "github_repository" {
  metadata {
    name      = "github-repository"
    namespace = kubernetes_namespace.argocd.metadata[0].name

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    type          = "git"
    url           = var.repository_url
    sshPrivateKey = var.repository_private_key
  }

  depends_on = [
    helm_release.argocd
  ]
}