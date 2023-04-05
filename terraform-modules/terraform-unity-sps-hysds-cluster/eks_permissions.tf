# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1990
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1943#issuecomment-1369546028
resource "kubernetes_secret" "sps-api" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = "sps-api-sa"
    }
    namespace     = kubernetes_namespace.unity-sps.metadata[0].name
    generate_name = "${kubernetes_service_account.sps-api.metadata[0].name}-token-"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

resource "kubernetes_service_account" "sps-api" {
  metadata {
    name      = "sps-api-sa"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
}

resource "kubernetes_role" "verdi-reader" {
  metadata {
    name      = "verdi-reader"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "verdi-reader-binding" {
  metadata {
    name      = "verdi-reader-binding"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.verdi-reader.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.sps-api.metadata[0].name
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
}
