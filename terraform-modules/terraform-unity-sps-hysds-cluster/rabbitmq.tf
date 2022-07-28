resource "kubernetes_service" "rabbitmq-mgmt-service" {
  metadata {
    name      = "rabbitmq-mgmt"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    selector = {
      app = "rabbitmq"
    }
    # TODO - Check on this parameter
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    port {
      name        = "cluster-rpc"
      port        = 15672
      target_port = 15672
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.rabbitmq_mgmt_service_cluster_rpc
    }
    type = var.service_type
  }
}



resource "kubernetes_service" "rabbitmq-service" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    type = var.service_type
    selector = {
      app = "rabbitmq"
    }
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    port {
      name        = "epmd"
      protocol    = "TCP"
      port        = 4369
      target_port = 4369
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.rabbitmq_service_epmd
    }
    port {
      name        = "listener"
      protocol    = "TCP"
      port        = 5672
      target_port = 5672
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.rabbitmq_service_listener
    }
    port {
      name        = "cluster-rpc"
      protocol    = "TCP"
      port        = 15672
      target_port = 15672
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.rabbitmq_service_cluster_rpc
    }
  }

}



resource "kubernetes_stateful_set" "rabbitmq_statefulset" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    service_name = "rabbitmq"
    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }
    template {
      metadata {
        labels = {
          app = "rabbitmq"
        }
      }
      spec {
        container {
          name  = "rabbitmq"
          image = var.docker_images.rabbitmq
          env {
            name  = "RABBITMQ_ERLANG_COOKIE"
            value = "1WqgH8N2v1qDBDZDbNy8Bg9IkPWLEpu79m6q+0t36lQ="
          }
          volume_mount {
            mount_path = "/var/lib/rabbitmq"
            name       = "rabbitmq-data"
          }
        }
        volume {
          name = "rabbitmq-data"
          host_path {
            path = "/data/rabbitmq"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}
