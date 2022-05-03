resource "kubernetes_secret" "container-registry" {
  metadata {
    name      = "container-registry"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.container_registry_server}" = {
          "username" = var.container_registry_username
          "password" = var.container_registry_password
          "auth"     = base64encode("${var.container_registry_username}:${var.container_registry_password}")
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}
