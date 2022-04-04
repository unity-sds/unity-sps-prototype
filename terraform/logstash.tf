
resource "kubernetes_deployment" "logstash" {
  metadata {
    name      = "logstash"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
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
        container {
          image   = "logstash:7.9.3"
          name    = "logstash"
          command = ["bin/logstash"]
          args    = ["-f", "/usr/share/logstash/logstash.conf"]

          port {
            container_port = 5044
          }

          volume_mount {
            name       = "logstash-conf"
            mount_path = "/usr/share/logstash/logstash.conf"
            sub_path   = "logstash.cfg"
            read_only  = false
          }

          volume_mount {
            name       = "job-status-mapping"
            mount_path = "/usr/share/logstash/job_status.template.json"
            sub_path   = "job_status.template.json"
            read_only  = false
          }

          volume_mount {
            name       = "task-status-mapping"
            mount_path = "/usr/share/logstash/task_status.template.json"
            sub_path   = "taks_status.template.json"
            read_only  = false
          }

          volume_mount {
            name       = "event-status-mapping"
            mount_path = "/usr/share/logstash/event_status.template.json"
            sub_path   = "event_status.template.json"
            read_only  = false
          }

          volume_mount {
            name       = "worker-status-mapping"
            mount_path = "/usr/share/logstash/worker_status.template.json"
            sub_path   = "worker_status.template.json"
            read_only  = false
          }

          volume_mount {
            name       = "logstash-yml"
            mount_path = "/usr/share/logstash/config/logstash.yml"
            sub_path   = "logstash.yml"
            read_only  = false
          }

        }

        volume {
          name = "logstash-conf"
          config_map {
            name = "logstash-configs"
            items {
              key  = "logstash-conf"
              path = "logstash.conf"
            }
          }
        }

        volume {
          name = "job-status-mapping"
          config_map {
            name = "logstash-configs"
            items {
              key  = "job-status"
              path = "job_status.template.json"
            }
          }
        }

        volume {
          name = "task-status-mapping"
          config_map {
            name = "logstash-configs"
            items {
              key  = "task-status"
              path = "taks_status.template.json"
            }
          }
        }

        volume {
          name = "event-status-mapping"
          config_map {
            name = "logstash-configs"
            items {
              key  = "event-status"
              path = "event_status.template.json"
            }
          }
        }

        volume {
          name = "worker-status-mapping"
          config_map {
            name = "logstash-configs"
            items {
              key  = "worker-status"
              path = "worker_status.template.json"
            }
          }
        }

        volume {
          name = "logstash-yml"
          config_map {
            name = "logstash-configs"
            items {
              key  = "logstash-yml"
              path = "logstash.yml"
            }
          }
        }
      }
    }

  }
}
