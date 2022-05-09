resource "kubernetes_deployment" "verdi" {
  metadata {
    name      = "verdi"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "verdi"
    }
  }
  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "verdi"
      }
    }
    template {
      metadata {
        labels = {
          app = "verdi"
        }
      }
      spec {
        init_container {
          name    = "change-ownership"
          image   = var.busybox_image
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            chmod 777 /var/run/docker.sock;
            chown -R 1000:1000 /private/tmp/data;
            EOT
          ]
          volume_mount {
            name       = "docker-sock"
            mount_path = "/var/run/docker.sock"
          }
          volume_mount {
            name       = "data-work"
            mount_path = "/private/tmp/data"
          }
        }
        container {
          name    = "verdi"
          image   = var.hysds_verdi_image
          command = ["supervisord", "--nodaemon"]

          volume_mount {
            name       = "docker-sock"
            mount_path = "/var/run/docker.sock"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.celeryconfig.metadata.0.name
            mount_path = "/home/ops/hysds/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.datasets.metadata.0.name
            mount_path = "/home/ops/datasets.json"
            sub_path   = "datasets.json"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.supervisord-verdi.metadata.0.name
            mount_path = "/etc/supervisord.conf"
            sub_path   = "supervisord.conf"
            read_only  = false
          }
          volume_mount {
            name       = kubernetes_config_map.aws-credentials.metadata.0.name
            mount_path = "/home/ops/.aws/credentials"
            sub_path   = "aws-credentials"
            read_only  = false
          }
          volume_mount {
            name       = "data-work"
            mount_path = "/private/tmp/data"
            read_only  = false
          }
        }
        image_pull_secrets {
          name = kubernetes_secret.container-registry.metadata.0.name
        }
        volume {
          name = "docker-sock"
          host_path {
            path = "/var/run/docker.sock"
          }
        }
        volume {
          name = kubernetes_config_map.celeryconfig.metadata.0.name
          config_map {
            name = kubernetes_config_map.celeryconfig.metadata.0.name
          }
        }
        volume {
          name = kubernetes_config_map.datasets.metadata.0.name
          config_map {
            name = kubernetes_config_map.datasets.metadata.0.name
          }
        }
        volume {
          name = kubernetes_config_map.supervisord-verdi.metadata.0.name
          config_map {
            name = kubernetes_config_map.supervisord-verdi.metadata.0.name
          }
        }
        volume {
          name = kubernetes_config_map.aws-credentials.metadata.0.name
          config_map {
            name = kubernetes_config_map.aws-credentials.metadata.0.name
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
