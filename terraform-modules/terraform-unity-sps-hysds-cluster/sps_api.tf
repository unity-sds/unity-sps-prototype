resource "kubernetes_service" "sps-api-service" {
  metadata {
    name      = "sps-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    selector = {
      app = "sps-api"
    }
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    type             = var.service_type
    port {
      protocol    = "TCP"
      port        = var.service_port_map.sps_api_service
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "sps-api" {
  metadata {
    name      = "sps-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "sps-api"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "sps-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "sps-api"
        }
      }
      spec {
        container {
          image             = var.docker_images.sps_api
          image_pull_policy = "Always"
          name              = "sps-api"
          port {
            container_port = 80
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
