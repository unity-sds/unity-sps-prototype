resource "kubernetes_deployment" "factotum-job-worker" {
  metadata {
    name      = "factotum-job-worker"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
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
        node_selector = {
          "eks.amazonaws.com/nodegroup" = var.default_group_node_group_name
        }
        init_container {
          name    = "change-ownership"
          image   = var.docker_images.busybox
          command = ["/bin/sh", "-c"]
          # https://stackoverflow.com/questions/56155495/how-do-i-copy-a-kubernetes-configmap-to-a-write-enabled-area-of-a-pod
          args = [
            <<-EOT
            chown -R 1000:1000 /tmp;
            EOT
          ]
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        container {
          # Docker container that runs a Docker engine ("Docker-IN-Docker" pattern)
          # After starting, the Docker socket is made available to the Vedri container
          # so that Verdi can execute Docker commands vs this engine
          name  = "dind-daemon"
          image = var.docker_images.dind
          #image = "docker:dind-rootless"
          env {
            name  = "DOCKER_TLS_CERTDIR"
            value = ""
          }
          resources {
            requests = {
              cpu    = "20m"
              memory = "512Mi"
            }
          }
          security_context {
            privileged = true
          }
          args = ["--tls=false"]
          lifecycle {
            post_start {
              exec {
                # Note: must wait a few seconds for the Docker engine to start and the file to be created
                command = [
                  "bin/sh",
                  "-c",
                  "sleep 5; chmod 777 /var/run/docker.sock"
                ]
              }
            }
          }
          # Empty directory where the Docker engine indices the images
          volume_mount {
            name       = "docker-graph-storage"
            mount_path = "/var/lib/docker"
          }
          # The Docker socket must be shared with Verdi container
          volume_mount {
            name       = "docker-sock-dir"
            mount_path = "/var/run"
            sub_path   = "docker.sock"
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        container {
          #image   = var.docker_images.hysds_factotum
          image             = var.docker_images.hysds_verdi
          image_pull_policy = "Always"
          name              = "factotum-job-worker"
          command           = ["supervisord", "--nodaemon"]
          env {
            name  = "DOCKER_HOST"
            value = "tcp://localhost:2375"
          }

          # volume_mount {
          #   name       = "docker-sock"
          #   mount_path = "/var/run/docker.sock"
          #   read_only  = false
          # }
          # The Docker socket use to communicate with the Docker engine
          volume_mount {
            name       = "docker-sock-dir"
            mount_path = "/var/run"
            sub_path   = "docker.sock"
          }

          volume_mount {
            name       = kubernetes_config_map.celeryconfig.metadata[0].name
            mount_path = "/home/ops/hysds/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.datasets.metadata[0].name
            mount_path = "/home/ops/datasets.json"
            sub_path   = "datasets.json"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.supervisord-job-worker.metadata[0].name
            mount_path = "/home/ops/supervisord.conf"
            sub_path   = "supervisord.conf"
            read_only  = false
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
            read_only  = false
          }
        }

        # volume {
        #   name = "docker-sock"
        #   host_path {
        #     path = "/var/run/docker.sock"
        #   }
        # }
        volume {
          name = kubernetes_config_map.celeryconfig.metadata[0].name
          config_map {
            name = kubernetes_config_map.celeryconfig.metadata[0].name
          }
        }

        volume {
          name = kubernetes_config_map.datasets.metadata[0].name
          config_map {
            name = kubernetes_config_map.datasets.metadata[0].name
          }
        }

        volume {
          name = kubernetes_config_map.supervisord-job-worker.metadata[0].name
          config_map {
            name = kubernetes_config_map.supervisord-job-worker.metadata[0].name
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }
        # Shared direcrtory holding the Docker socket
        volume {
          name = "docker-sock-dir"
          empty_dir {}
        }
        # Clean Docker storage
        volume {
          name = "docker-graph-storage"
          empty_dir {}
        }
      }
    }
  }
}
