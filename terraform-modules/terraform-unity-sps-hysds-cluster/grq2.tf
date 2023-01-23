
resource "kubernetes_service" "grq2-service" {
  metadata {
    name      = "grq2"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    selector = {
      app = "grq2"
    }
    port {
      port        = var.service_port_map.grq2_service
      target_port = 8878
    }
  }
}



resource "kubernetes_deployment" "grq2" {
  metadata {
    name      = "grq2"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "grq2"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "grq2"
      }
    }

    template {
      metadata {
        labels = {
          app = "grq2"
        }
      }

      spec {
        container {
          image = var.docker_images.hysds_grq2
          name  = "grq2"

          port {
            container_port = 8878
            name           = "grq2"
          }

          volume_mount {
            name       = kubernetes_config_map.grq2-settings.metadata[0].name
            mount_path = "/home/ops/grq2/settings.cfg"
            sub_path   = "settings.cfg"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.celeryconfig.metadata[0].name
            mount_path = "/home/ops/grq2/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.netrc.metadata[0].name
            mount_path = "/home/ops/.netrc"
            sub_path   = ".netrc"
            read_only  = false
          }

        }

        volume {
          name = kubernetes_config_map.grq2-settings.metadata[0].name
          config_map {
            name = kubernetes_config_map.grq2-settings.metadata[0].name
          }
        }

        volume {
          name = kubernetes_config_map.celeryconfig.metadata[0].name
          config_map {
            name = kubernetes_config_map.celeryconfig.metadata[0].name
          }
        }

        volume {
          name = kubernetes_config_map.netrc.metadata[0].name
          config_map {
            name = kubernetes_config_map.netrc.metadata[0].name
          }
        }

      }
    }

  }
}
