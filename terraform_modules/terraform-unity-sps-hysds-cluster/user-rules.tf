resource "kubernetes_deployment" "user-rules" {
  metadata {
    name      = "user-rules"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "user-rules"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "user-rules"
      }
    }

    template {
      metadata {
        labels = {
          app = "user-rules"
        }
      }

      spec {
        security_context {
          run_as_user  = 0
          run_as_group = 0
        }
        container {
          image   = var.docker_images.hysds_core
          name    = "user-rules"
          command = ["supervisord", "--nodaemon"]

          volume_mount {
            name       = kubernetes_config_map.celeryconfig.metadata.0.name
            mount_path = "/home/ops/hysds/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.supervisord-user-rules.metadata.0.name
            mount_path = "/etc/supervisord.conf"
            sub_path   = "supervisord.conf"
            read_only  = false
          }

          volume_mount {
            name       = "data-work"
            mount_path = "/private/tmp/data"
            read_only  = false
          }
        }

        volume {
          name = kubernetes_config_map.celeryconfig.metadata.0.name
          config_map {
            name = kubernetes_config_map.celeryconfig.metadata.0.name
          }
        }

        volume {
          name = kubernetes_config_map.supervisord-user-rules.metadata.0.name
          config_map {
            name = kubernetes_config_map.supervisord-user-rules.metadata.0.name
          }
        }

        volume {
          name = "data-work"
          host_path {
            path = "/private/tmp/data"
          }
        }
      }
    }
  }
}
