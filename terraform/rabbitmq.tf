
resource "kubernetes_service" "rabbitmq_mgmt_service" {
  metadata {
    name = "rabbitmq-mgmt"
  }

  spec {
    selector = {
      app = "rabbitmq"
    }
    # TODO - Check on this parameter
    session_affinity = "ClientIP"
    port {
      name        = "cluster-rpc"
      port        = 15672
      target_port = 15672
    }
    type = "LoadBalancer"
  }

}

resource "kubernetes_service" "rabbitmq_service" {
  metadata {
    name = "rabbitmq"
  }

  spec {
    type = "NodePort"
    selector = {
      app = "rabbitmq"
    }
    session_affinity = "ClientIP"
    port {
      name        = "epmd"
      protocol    = "TCP"
      port        = 4369
      target_port = 4369
    }
    port {
      name        = "listener"
      protocol    = "TCP"
      port        = 5672
      target_port = 5672
    }
    port {
      name        = "cluster-rpc"
      protocol    = "TCP"
      port        = 15672
      target_port = 15672
    }
  }

}

resource "kubernetes_stateful_set" "rabbitmq_statefulset" {
  metadata {
    name = "rabbitmq"
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
          image = "rabbitmq:3-management"
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
