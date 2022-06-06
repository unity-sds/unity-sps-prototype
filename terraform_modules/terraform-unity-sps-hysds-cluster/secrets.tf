locals {
  container_registry_auths = {
    auths = {
      "${var.container_registry.server}" = {
        "username" = var.container_registry.username
        "password" = var.container_registry.password
        "auth"     = base64encode("${var.container_registry.username}:${var.container_registry.password}")
      }
    }
  }
}
resource "kubernetes_secret" "container-registry" {
  metadata {
    name      = "container-registry"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.container_registry_auths)
  }
  type = "kubernetes.io/dockerconfigjson"
}
