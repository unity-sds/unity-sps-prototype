resource "kubernetes_service" "mozart_service" {
  metadata {
    name      = "mozart"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }

  spec {
    selector = {
      app = "mozart"
    }
#    session_affinity = "ClientIP"
    port {
      port        = 8888
      target_port = 8888
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.mozart_service
    }
    type = var.service_type
  }
}


resource "kubernetes_deployment" "mozart" {
  metadata {
    name      = "mozart"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "mozart"
    }
  }

  spec {
    # replicas = 3

    selector {
      match_labels = {
        app = "mozart"
      }
    }

    template {
      metadata {
        labels = {
          app = "mozart"
        }
      }

      spec {
        container {
          image = var.docker_images.hysds_mozart
          name  = "mozart"

          #resources {
          #  limits = {
          #    cpu    = "0.5"
          #    memory = "512Mi"
          #  }
          #  requests = {
          #    cpu    = "250m"
          #    memory = "50Mi"
          #  }
          #}

          port {
            container_port = 8888
            name           = "mozart"
          }

          volume_mount {
            name       = kubernetes_config_map.mozart-settings.metadata.0.name
            mount_path = "/home/ops/mozart/settings.cfg"
            sub_path   = "settings.cfg"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.celeryconfig.metadata.0.name
            mount_path = "/home/ops/mozart/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.netrc.metadata.0.name
            mount_path = "/home/ops/.netrc"
            sub_path   = ".netrc"
            read_only  = false
          }

        }

        volume {
          name = kubernetes_config_map.mozart-settings.metadata.0.name
          config_map {
            name = kubernetes_config_map.mozart-settings.metadata.0.name
          }
        }

        volume {
          name = kubernetes_config_map.celeryconfig.metadata.0.name
          config_map {
            name = kubernetes_config_map.celeryconfig.metadata.0.name
          }
        }

        volume {
          name = kubernetes_config_map.netrc.metadata.0.name
          config_map {
            name = kubernetes_config_map.netrc.metadata.0.name
          }
        }
      }
    }

  }
}
