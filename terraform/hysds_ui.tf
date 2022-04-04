
resource "kubernetes_service" "hysds-ui_service" {
  metadata {
    name      = "hysds-ui"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  spec {
    selector = {
      app = "hysds-ui"
    }
    session_affinity = "ClientIP"
    port {
      protocol    = "TCP"
      port        = 3000
      target_port = 80
      node_port   = 31000
    }
    type = "LoadBalancer"
  }

}


resource "kubernetes_deployment" "hysds-ui" {
  metadata {
    name      = "hysds-ui"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }

  spec {
    selector {
      match_labels = {
        app = "hysds-ui"
      }
    }

    template {
      metadata {
        labels = {
          app = "hysds-ui"
        }
      }

      spec {
        container {
          image = "hysds-ui:unity-v0.0.1"
          name  = "hysds-ui"

          port {
            container_port = 80
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
