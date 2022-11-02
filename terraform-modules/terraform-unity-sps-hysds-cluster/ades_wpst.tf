
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
      port        = var.service_port_map.ades_wpst_api_service
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
          image             = var.docker_images.ades_wpst_api
          image_pull_policy = "Always"
          name              = "ades-wpst-api"
          env {
            name  = "ADES_PLATFORM"
            value = "HYSDS"
          }
          port {
            container_port = 5000
          }
          volume_mount {
            name       = "sqlite-db"
            mount_path = "/flask_ades_wpst/sqlite"
          }
        }
        volume {
          name = "sqlite-db"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim.metadata[0].name
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
