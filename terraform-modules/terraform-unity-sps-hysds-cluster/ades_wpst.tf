
resource "kubernetes_persistent_volume_claim" "ades-wpst-sqlite-pv-claim" {
  metadata {
    name      = "ades-wpst-sqlite-pv-claim"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "ades-wpst-sqlite-storage-claim"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}


resource "kubernetes_service" "ades-wpst-api-service" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    selector = {
      app = "ades-wpst-api"
    }
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    type             = var.service_type
    port {
      protocol    = "TCP"
      port        = 5001
      target_port = 5000
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.ades_wpst_api_service
    }
  }
}

resource "kubernetes_deployment" "ades-wpst-api" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "ades-wpst-api"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "ades-wpst-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "ades-wpst-api"
        }
      }
      spec {
        container {
          name  = "dind-daemon"
          image = "docker:dind"
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
        }
        container {
          image             = var.docker_images.ades_wpst_api
          image_pull_policy = "Always"
          name              = "ades-wpst-api"
          env {
            name  = "ADES_PLATFORM"
            value = "HYSDS"
          }
          env {
            name  = "DOCKER_HOST"
            value = "tcp://localhost:2375"
          }
          port {
            container_port = 5000
          }
          volume_mount {
            name       = "sqlite-db"
            mount_path = "/flask_ades_wpst/sqlite"
          }
          # The Docker socket use to communicate with the Docker engine
          volume_mount {
            name       = "docker-sock-dir"
            mount_path = "/var/run"
            sub_path   = "docker.sock"
          }
        }
        volume {
          name = "sqlite-db"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim.metadata[0].name
          }
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
        restart_policy = "Always"
      }
    }
  }
}
