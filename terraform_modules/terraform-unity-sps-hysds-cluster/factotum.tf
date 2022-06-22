resource "kubernetes_deployment" "factotum-job-worker" {
  metadata {
    name      = "factotum-job-worker"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "factotum-job-worker"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "factotum-job-worker"
      }
    }

    template {
      metadata {
        labels = {
          app = "factotum-job-worker"
        }
      }

      spec {
        init_container {
          name    = "changeume-ownership"
          image   = var.docker_images.busybox
          command = ["/bin/sh", "-c", "chmod 777 /var/run/docker.sock; chown -R 1000:1000 /private/tmp/data;"]
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
          #image   = var.docker_images.hysds_factotum
          image   = var.docker_images.hysds_verdi
          name    = "factotum-job-worker"
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
            name       = kubernetes_config_map.supervisord-job-worker.metadata.0.name
            mount_path = "/home/ops/supervisord.conf"
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
          name = kubernetes_config_map.supervisord-job-worker.metadata.0.name
          config_map {
            name = kubernetes_config_map.supervisord-job-worker.metadata.0.name
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
