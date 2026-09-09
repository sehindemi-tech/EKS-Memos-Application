resource "helm_release" "argocd" {
  name             = var.argocd_config.name
  repository       = var.argocd_config.repository
  chart            = var.argocd_config.chart
  version          = var.argocd_config.version
  namespace        = var.argocd_config.namespace
  create_namespace = var.argocd_config.create_namespace
  values = [
    file("${path.module}/values/argo-cd.yaml")
  ]
}





