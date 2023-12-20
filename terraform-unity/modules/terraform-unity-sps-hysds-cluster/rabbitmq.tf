resource "kubernetes_service" "rabbitmq-mgmt-service" {
  metadata {
    name      = "rabbitmq-mgmt"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    selector = {
      app = "rabbitmq"
    }
    port {
      name        = "cluster-rpc"
      port        = var.service_port_map.rabbitmq_mgmt_service_cluster_rpc
      target_port = 15672
    }
  }
}



resource "kubernetes_service" "rabbitmq-service" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }

  spec {
    selector = {
      app = "rabbitmq"
    }
    port {
      name        = "epmd"
      protocol    = "TCP"
      port        = var.service_port_map.rabbitmq_service_epmd
      target_port = 4369
    }
    port {
      name        = "listener"
      protocol    = "TCP"
      port        = var.service_port_map.rabbitmq_service_listener
      target_port = 5672
    }
    port {
      name        = "cluster-rpc"
      protocol    = "TCP"
      port        = var.service_port_map.rabbitmq_service_cluster_rpc
      target_port = 15672
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
          lifecycle {
            post_start {
              exec {
                command = [
                  "/bin/sh",
                  "-c",
                  <<-EOT
                  sleep 5; rabbitmqctl eval 'application:set_env(rabbit, consumer_timeout, 172800000).'
                  EOT
                ]
              }
            }
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