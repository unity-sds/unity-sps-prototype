resource "kubernetes_deployment" "logstash" {
  metadata {
    name      = "logstash"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "logstash"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "logstash"
      }
    }

    template {
      metadata {
        labels = {
          app = "logstash"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = var.eks_node_groups
        }
        container {
          image   = var.docker_images.logstash
          name    = "logstash"
          command = ["bin/logstash"]
          args    = ["-f", "/usr/share/logstash/logstash.conf"]

          port {
            container_port = 5044
          }

          # volume_mount {
          #   name       = "logstash-conf"
          #   mount_path = "/usr/share/logstash/logstash.conf"
          #   sub_path   = "logstash.cfg"
          #   read_only  = false
          # }

          # volume_mount {
          #   name       = "job-status-mapping"
          #   mount_path = "/usr/share/logstash/job_status.template.json"
          #   sub_path   = "job_status.template.json"
          #   read_only  = false
          # }

          # volume_mount {
          #   name       = "task-status-mapping"
          #   mount_path = "/usr/share/logstash/task_status.template.json"
          #   sub_path   = "task_status.template.json"
          #   read_only  = false
          # }

          # volume_mount {
          #   name       = "event-status-mapping"
          #   mount_path = "/usr/share/logstash/event_status.template.json"
          #   sub_path   = "event_status.template.json"
          #   read_only  = false
          # }

          # volume_mount {
          #   name       = "worker-status-mapping"
          #   mount_path = "/usr/share/logstash/worker_status.template.json"
          #   sub_path   = "worker_status.template.json"
          #   read_only  = false
          # }

          # volume_mount {
          #   name       = "logstash-yml"
          #   mount_path = "/usr/share/logstash/config/logstash.yml"
          #   sub_path   = "logstash.yml"
          #   read_only  = false
          # }
          volume_mount {
            name       = kubernetes_config_map.logstash-configs.metadata[0].name
            mount_path = "/usr/share/logstash/logstash.conf"
            sub_path   = "logstash-conf"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.logstash-configs.metadata[0].name
            mount_path = "/usr/share/logstash/job_status.template.json"
            sub_path   = "job-status"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.logstash-configs.metadata[0].name
            mount_path = "/usr/share/logstash/task_status.template.json"
            sub_path   = "task-status"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.logstash-configs.metadata[0].name
            mount_path = "/usr/share/logstash/event_status.template.json"
            sub_path   = "event-status"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.logstash-configs.metadata[0].name
            mount_path = "/usr/share/logstash/worker_status.template.json"
            sub_path   = "worker-status"
            read_only  = false
          }

          volume_mount {
            name       = kubernetes_config_map.logstash-configs.metadata[0].name
            mount_path = "/usr/share/logstash/config/logstash.yml"
            sub_path   = "logstash-yml"
            read_only  = false
          }
        }
        volume {
          name = kubernetes_config_map.logstash-configs.metadata[0].name
          config_map {
            name = kubernetes_config_map.logstash-configs.metadata[0].name
          }
        }

        # volume {
        #   name = "logstash-conf"
        #   config_map {
        #     name = "logstash-conf"
        #   }
        # }

        # volume {
        #   name = "job-status-mapping"
        #   config_map {
        #     name = "logstash-job-status"
        #   }
        # }

        # volume {
        #   name = "task-status-mapping"
        #   config_map {
        #     name = "logstash-task-status"
        #   }
        # }

        # volume {
        #   name = "event-status-mapping"
        #   config_map {
        #     name = "logstash-event-status"
        #   }
        # }

        # volume {
        #   name = "worker-status-mapping"
        #   config_map {
        #     name = "logstash-worker-status"
        #   }
        # }

        # volume {
        #   name = "logstash-yml"
        #   config_map {
        #     name = "logstash-yml"
        #   }
        # }
      }
    }

  }
}
