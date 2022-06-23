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
        # security_context {
        #   run_as_user  = 1000
        #   run_as_group = 3000
        #   fs_group     = 2000
        #   # fs_group        = 1000
        #   # run_as_group    = 1000
        #   # run_as_non_root = true
        #   # run_as_user     = 1000
        # }
        init_container {
          name    = "change-ownership"
          image   = var.docker_images.busybox
          command = ["/bin/sh", "-c"]
          # args = [
          #   <<-EOT
          #   chmod 777 /var/run/docker.sock;
          #   chown -R 1000:1000 /private/tmp/data;
          #   EOT
          # ]
          args = [
            <<-EOT
            chown -R 1000:1000 /private/tmp/data;
            EOT
          ]
          volume_mount {
            name       = "data-work"
            mount_path = "/private/tmp/data"
          }
        }
        container {
          # Docker container that runs a Docker engine ("Docker-IN-Docker" pattern)
          # After starting, the Docker socket is made available to the Vedri container
          # so that Verdi can execute Docker commands vs this engine
          name  = "dind-daemon"
          image = "docker:dind"
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
            #allow_privilege_escalation = true
          }
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
          # Note: the /tmp directory must be shared
          # because cwl-runner mounts it from the client into the container
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
        }
        container {
          name    = "verdi"
          image   = var.docker_images.hysds_verdi
          command = ["supervisord", "--nodaemon"]
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
          # A persistent volume storing static data
          volume_mount {
            name       = "static-data"
            mount_path = "/static-data"
          }
          # Directory containing the Sounder Sips specific workflow
          # TODO: remove and make it part of the deployment phase
          volume_mount {
            name       = "src-dir"
            mount_path = "/src"
          }
          # Temporary directory shared with the DIND container
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
        }
        # volume {
        #   name = "docker-sock"
        #   host_path {
        #     path = "/var/run/docker.sock"
        #   }
        # }
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
        # Shared direcrtory holding the Docker socket
        volume {
          name = "docker-sock-dir"
          empty_dir {}
        }
        # TODO: replace with an independent persistent volume holding static data
        volume {
          name = "static-data"
          host_path {
            path = abspath("${path.module}/../../dev_data/SOUNDER_SIPS/STATIC_DATA")
          }
        }
        # TODO: remove and access the CWL workflow during the algorithm deployment
        volume {
          name = "src-dir"
          host_path {
            path = abspath("${path.module}/../../workflows/sounder_SIPS")
          }
        }
        # Temporary directory shared between containers (used by CWL workflow)
        volume {
          name = "tmp-dir"
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
