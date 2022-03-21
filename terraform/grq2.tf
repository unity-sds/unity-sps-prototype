
resource "kubernetes_service" "grq2_service" {
  metadata {
    name = "grq2"
  }

  spec {
    selector = {
      app = "grq2"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8878
      target_port = 8878
    }

    type = "LoadBalancer"
  }

}


resource "kubernetes_deployment" "grq2" {
  metadata {
    name = "grq2"
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
          image = "hysds-grq2:unity-v0.0.1"
          name  = "grq2"

          port {
            container_port = 8878
            name           = "grq2"
          }

          volume_mount {
            name       = "grq2-settings"
            mount_path = "/home/ops/grq2/settings.cfg"
            sub_path   = "settings.cfg"
            read_only  = false
          }

          volume_mount {
            name       = "celeryconfig"
            mount_path = "/home/ops/grq2/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = "netrc"
            mount_path = "/home/ops/.netrc"
            sub_path   = ".netrc"
            read_only  = false
          }

        }

        volume {
          name = "grq2-settings"
          config_map {
            name = "grq2-settings"
          }
        }

        volume {
          name = "celeryconfig"
          config_map {
            name = "celeryconfig"
          }
        }

        volume {
          name = "netrc"
          config_map {
            name = "netrc"
          }
        }

      }
    }

  }
}
