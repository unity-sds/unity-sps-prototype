resource "kubernetes_service" "hysds-ui-service" {
  metadata {
    name      = "hysds-ui"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    selector = {
      app = "hysds-ui"
    }
    port {
      port        = var.service_port_map.hysds_ui_service
      target_port = 80
    }
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
        node_selector = {
          "eks.amazonaws.com/nodegroup" = var.default_group_node_group_name
        }
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
