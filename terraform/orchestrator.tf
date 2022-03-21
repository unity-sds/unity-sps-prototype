resource "kubernetes_deployment" "orchestrator" {
  metadata {
    name = "orchestrator"
    labels = {
      app = "orchestrator"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "orchestrator"
      }
    }

    template {
      metadata {
        labels = {
          app = "orchestrator"
        }
      }

      spec {
        security_context {
          run_as_user  = 0
          run_as_group = 0
        }
        container {
          image   = "hysds-core:unity-v0.0.1"
          name    = "orchestrator"
          command = ["supervisord", "--nodaemon"]

          volume_mount {
            name       = "celeryconfig"
            mount_path = "/home/ops/factotum/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = "supervisord-orchestrator"
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
          name = "supervisord-orchestrator"
          config_map {
            name = "supervisord-orchestrator"
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


