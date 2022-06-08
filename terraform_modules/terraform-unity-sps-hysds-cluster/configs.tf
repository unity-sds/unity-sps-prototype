resource "kubernetes_config_map" "mozart-settings" {
  metadata {
    name      = "mozart-settings"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "settings.cfg" = "${file("${path.module}/../../hysds/mozart/rest_api/settings.cfg")}"
  }
}

resource "kubernetes_config_map" "celeryconfig" {
  metadata {
    name      = "celeryconfig"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "celeryconfig.py" = "${file("${path.module}/../../hysds/configs/${var.celeryconfig_filename}")}"
  }
}

resource "kubernetes_config_map" "netrc" {
  metadata {
    name      = "netrc"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    ".netrc" = "${file("${path.module}/../../hysds/configs/.netrc")}"
  }
}


resource "kubernetes_config_map" "supervisord-user-rules" {
  metadata {
    name      = "supervisord-user-rules"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    "supervisord.conf" = "${file("${path.module}/../../hysds/user_rules/supervisord.conf")}"
  }
}
