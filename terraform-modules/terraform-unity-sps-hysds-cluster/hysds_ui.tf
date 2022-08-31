resource "kubernetes_service" "hysds-ui-service" {
  metadata {
    name      = "hysds-ui"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    selector = {
      app = "hysds-ui"
    }
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    port {
      protocol    = "TCP"
      port        = 3000
      target_port = 80
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.hysds_ui_service
    }
    type = var.service_type
  }
}


resource "kubernetes_deployment" "hysds-ui" {
  metadata {
    name      = "hysds-ui"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
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
          image             = var.docker_images.hysds_ui
          image_pull_policy = "Always"
          name              = "hysds-ui"
          port {
            container_port = 80
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
