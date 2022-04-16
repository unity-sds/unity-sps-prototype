
resource "kubernetes_service" "redis_service" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }

  spec {
    selector = {
      app = "redis"
    }
    session_affinity = "ClientIP"
    port {
      port        = 6379
      target_port = 6379
    }

    type = "NodePort"
  }

}


resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "redis"
    }
  }

  spec {
    # replicas = 3

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        namespace = kubernetes_namespace.unity-sps.metadata.0.name
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          image             = var.redis_image
          name              = "redis"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}
