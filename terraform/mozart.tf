
resource "kubernetes_service" "mozart_service" {

  metadata {
    name = "mozart"
  }

  spec {
    selector = {
      app = "mozart"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8888
      target_port = 8888
    }

    type = "LoadBalancer"
  }

}


resource "kubernetes_deployment" "mozart" {

  metadata {
    name = "mozart"
    labels = {
      app = "mozart"
    }
  }

  spec {
    # replicas = 3

    selector {
      match_labels = {
        app = "mozart"
      }
    }
 
    template {
      metadata {
        labels = {
          app = "mozart"
        }
      }

      spec {
        container {
          image = "hysds-mozart:unity-v0.0.1"
          name  = "mozart"

          #resources {
          #  limits = {
          #    cpu    = "0.5"
          #    memory = "512Mi"
          #  }
          #  requests = {
          #    cpu    = "250m"
          #    memory = "50Mi"
          #  }
          #}

          port {
            container_port = 8888
            name = "mozart"
          }
          
          volume_mount {
            name       = "mozart-settings"
            mount_path = "/home/ops/mozart/settings.cfg"
            sub_path   = "settings.cfg"
            read_only   = false
          }

          volume_mount {
              name = "celeryconfig"
              mount_path  = "/home/ops/mozart/celeryconfig.py"
              sub_path    = "celeryconfig.py"
              read_only   = false
          }

          volume_mount {
              name = "netrc"
              mount_path  = "/home/ops/.netrc"
              sub_path    = ".netrc"
              read_only   = false
          }

        }

        volume {
          name = "mozart-settings"
          config_map {
            name = "mozart-settings"
          }
        }

        volume {
          name = "celeryconfig"
          config_map {
            name = "celeryconfig"
          }
        }

        volume {
          name = "netrc"
          config_map {
            name = "netrc"
          }
        }

      }
    }

  }
}
