
resource "kubernetes_persistent_volume_claim" "ades-wpst-sqlite-pv-claim" {
  metadata {
    name      = "ades-wpst-sqlite-pv-claim"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
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


resource "kubernetes_service" "ades-wpst-api_service" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  spec {
    selector = {
      app = "ades-wpst-api"
    }
    session_affinity = "ClientIP"
    port {
      protocol    = "TCP"
      port        = 5001
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}


resource "kubernetes_deployment" "ades-wpst-api" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
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
          image = var.ades_wpst_api_image
          name  = "ades-wpst-api"
          env {
            name  = "ADES_PLATFORM"
            value = "Generic"
          }
          port {
            container_port = 5000
          }
          volume_mount {
            name       = "sqlite-db"
            mount_path = "/ades_wpst/sqlite"
          }
        }
        image_pull_secrets {
          name = kubernetes_secret.container-registry.metadata.0.name
        }
        volume {
          name = "sqlite-db"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim.metadata.0.name
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
