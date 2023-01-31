resource "kubernetes_deployment" "verdi" {
  metadata {
    name      = "verdi"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
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
          image   = var.docker_images.busybox
          command = ["/bin/sh", "-c"]
          # https://stackoverflow.com/questions/56155495/how-do-i-copy-a-kubernetes-configmap-to-a-write-enabled-area-of-a-pod
          args = [
            <<-EOT
            chown -R 1000:1000 /uads-development-efs;
            chown -R 1000:1000 /tmp;
            cp -r /cwl-src/. /src;
            EOT
          ]
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = kubernetes_config_map.cwl-workflows.metadata[0].name
            mount_path = "/cwl-src"
          }
          volume_mount {
            name       = "src"
            mount_path = "/src"
          }
          volume_mount {
            name       = "uads-development-efs"
            mount_path = "/uads-development-efs"
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
          volume_mount {
            name       = "uads-development-efs"
            mount_path = "/uads-development-efs"
          }
        }
        container {
          name              = "verdi"
          image             = var.docker_images.hysds_verdi
          image_pull_policy = "Always"
          command           = ["supervisord", "--nodaemon"]
          env {
            name  = "STAGING_BUCKET"
            value = var.uds_staging_bucket
          }
          env {
            name  = "CLIENT_ID"
            value = var.uds_client_id
          }
          env {
            name  = "DAPA_API"
            value = var.uds_dapa_api
          }
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
            name       = kubernetes_config_map.supervisord-verdi.metadata[0].name
            mount_path = "/etc/supervisord.conf"
            sub_path   = "supervisord.conf"
            read_only  = false
          }
          # volume_mount {
          #   name       = "data-work"
          #   mount_path = "/tmp/data"
          #   read_only  = false
          # }
          # Directory containing the Sounder Sips specific workflow
          # TODO: remove and make it part of the deployment phase
          volume_mount {
            name       = "src"
            mount_path = "/src"
            read_only  = false
          }
          volume_mount {
            name       = kubernetes_config_map.cwl-workflow-utils.metadata[0].name
            mount_path = "/src/utils"
          }
          # Temporary directory shared with the DIND container
          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "uads-development-efs"
            mount_path = "/uads-development-efs"
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
          name = kubernetes_config_map.supervisord-verdi.metadata[0].name
          config_map {
            name = kubernetes_config_map.supervisord-verdi.metadata[0].name
          }
        }
        # volume {
        #   name = "data-work"
        #   host_path {
        #     path = "/tmp/data"
        #   }
        # }
        # Shared direcrtory holding the Docker socket
        volume {
          name = "docker-sock-dir"
          empty_dir {}
        }
        # TODO: remove and access the CWL workflow during the algorithm deployment
        volume {
          name = kubernetes_config_map.cwl-workflows.metadata[0].name
          config_map {
            name = kubernetes_config_map.cwl-workflows.metadata[0].name
          }
        }
        volume {
          name = kubernetes_config_map.cwl-workflow-utils.metadata[0].name
          config_map {
            name = kubernetes_config_map.cwl-workflow-utils.metadata[0].name
          }
        }
        volume {
          name = "src"
          empty_dir {}
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
        volume {
          name = "uads-development-efs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.uads-development-efs.metadata.0.name
          }
        }
      }
    }
  }
}
