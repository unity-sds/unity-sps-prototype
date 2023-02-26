resource "kubernetes_persistent_volume" "ades-wpst-sqlite-pv" {
  metadata {
    name = "ades-wpst-sqlite-pv"
  }

  spec {
    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata.0.name
    access_modes       = ["ReadWriteMany"]
    capacity = {
      storage = "20Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    # persistent_volume_source {
    #   nfs {
    #     server    = aws_efs_mount_target.hysds_efs_mt.ip_address
    #     path      = "/flask_ades_wpst/sqlite"
    #     read_only = false
    #   }
    # }

    persistent_volume_source {
      host_path {
        path = "/flask_ades_wpst/sqlite"
      }
    }
    # Link to the corresponding PVC using the volume_name
    # claim_ref {
    #   name = "ades-wpst-sqlite-pvc"
    # }
  }
}

resource "kubernetes_persistent_volume_claim" "ades-wpst-sqlite-pv-claim" {
  metadata {
    name      = "ades-wpst-sqlite-pv-claim"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "ades-wpst-sqlite-storage-claim"
    }
  }

  spec {
    storage_class_name = kubernetes_storage_class.efs_storage_class.metadata.0.name
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.ades-wpst-sqlite-pv.metadata.0.name
  }
}


# resource "kubernetes_persistent_volume_claim" "ades-wpst-sqlite-pv-claim" {
#   metadata {
#     name      = "ades-wpst-sqlite-pv-claim"
#     namespace = kubernetes_namespace.unity-sps.metadata[0].name
#     labels = {
#       app = "ades-wpst-sqlite-storage-claim"
#     }
#   }
#   spec {
#     storage_class_name = "${var.project}-${var.venue}-${var.service_area}-efs-sc"
#     access_modes       = ["ReadWriteOnce"]
#     resources {
#       requests = {
#         storage = "20Gi"
#       }
#     }
#     volume_name = kubernetes_persistent_volume.ades-wpst-sqlite-pv.metadata.0.name
#   }
# }

# resource "kubernetes_persistent_volume" "ades-wpst-sqlite-pv" {
#   metadata {
#     name = "ades-wpst-sqlite-pv"
#     labels = {
#       pv-name = "ades-wpst-sqlite-pv"
#     }
#   }
#   spec {
#     storage_class_name = "gp2"
#     access_modes       = ["ReadWriteOnce"]
#     capacity = {
#       storage = "20Gi"
#     }
#     persistent_volume_source {
#       host_path {
#         path = "/flask_ades_wpst/sqlite"
#       }
#     }
#   }
# }


resource "kubernetes_service" "ades-wpst-api-service" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    selector = {
      app = "ades-wpst-api"
    }
    type = var.service_type
    port {
      protocol    = "TCP"
      port        = var.service_port_map.ades_wpst_api_service
      target_port = 5000
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
          name              = "dind-daemon"
          image             = "docker:dind"
          image_pull_policy = "Always"
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
            name  = "CR_SERVER"
            value = var.container_registry_server
          }
          env {
            name  = "CR_USERNAME"
            value = var.container_registry_username
          }
          env {
            name  = "CR_PAT"
            value = var.container_registry_pat
          }
          env {
            name  = "CR_OWNER"
            value = var.container_registry_owner
          }
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
          # volume_mount {
          #   name       = "uads-development-efs"
          #   mount_path = "/uads-development-efs"
          # }
        }
        volume {
          name = "sqlite-db"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim.metadata.0.name
          }
        }
        # volume {
        #   name = "uads-development-efs"
        #   persistent_volume_claim {
        #     claim_name = kubernetes_persistent_volume_claim.uads-development-efs.metadata.0.name
        #   }
        # }
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
