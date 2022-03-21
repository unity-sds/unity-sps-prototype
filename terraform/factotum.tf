resource "kubernetes_deployment" "factotum-job-worker" {
  metadata {
    name = "factotum-job-worker"
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
          image   = "k8s.gcr.io/busybox"
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
          image   = "factotum:unity-v0.0.1"
          name    = "factotum-job-worker"
          command = ["supervisord", "--nodaemon"]

          volume_mount {
            name       = "docker-sock"
            mount_path = "/var/run/docker.sock"
            read_only  = false
          }

          volume_mount {
            name       = "celeryconfig"
            mount_path = "/home/ops/factotum/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = "datasets"
            mount_path = "/home/ops/datasets.json"
            sub_path   = "datasets.json"
            read_only  = false
          }

          volume_mount {
            name       = "supervisord-job-worker"
            mount_path = "/home/ops/supervisord.conf"
            sub_path   = "supervisord.conf"
            read_only  = false
          }
          volume_mount {
            name       = "aws-credentials"
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
          name = "celeryconfig"
          config_map {
            name = "celeryconfig"
          }
        }

        volume {
          name = "datasets"
          config_map {
            name = "datasets"
          }
        }

        volume {
          name = "supervisord-job-worker"
          config_map {
            name = "supervisord-job-worker"
          }
        }

        volume {
          name = "aws-credentials"
          config_map {
            name = "aws-credentials"
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


