resource "kubernetes_deployment" "user-rules" {
  metadata {
    name = "user-rules"
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
          image   = "hysds-core:unity-v0.0.1"
          name    = "user-rules"
          command = ["supervisord", "--nodaemon"]

          volume_mount {
            name       = "celeryconfig"
            mount_path = "/home/ops/factotum/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = "supervisord-user-rules"
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
          name = "celeryconfig"
          config_map {
            name = "celeryconfig"
          }
        }

        volume {
          name = "supervisord-user-rules"
          config_map {
            name = "supervisord-user-rules"
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


