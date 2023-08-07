provider "kubernetes" {
  config_path = var.kubeconfig_filepath
  insecure    = true
}


# resource "kubernetes_namespace" "unity-sps" {
#   metadata {
#     name = var.namespace
#   }
# }

resource "kubernetes_persistent_volume" "airflow_home_pv" {
  metadata {
    name = "airflow-home-pv"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.airflow_home
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "airflow_home_pvc" {
  metadata {
    name      = "airflow-home-pvc"
    namespace = "unity-sps"
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.airflow_home_pv.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "cwl_tmp_pv" {
  metadata {
    name = "cwl-tmp-pv"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.cwl_tmp_folder
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "cwl_tmp_pvc" {
  metadata {
    name      = "cwl-tmp-pvc"
    namespace = "unity-sps"
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.cwl_tmp_pv.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "cwl_inputs_pv" {
  metadata {
    name = "cwl-inputs-pv"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.cwl_inputs_folder
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "cwl_inputs_pvc" {
  metadata {
    name      = "cwl-inputs-pvc"
    namespace = "unity-sps"
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.cwl_inputs_pv.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "cwl_outputs_pv" {
  metadata {
    name = "cwl-outputs-pv"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.cwl_outputs_folder
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "cwl_outputs_pvc" {
  metadata {
    name      = "cwl-outputs-pvc"
    namespace = "unity-sps"
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.cwl_outputs_pv.metadata[0].name
  }
}

resource "kubernetes_persistent_volume" "cwl_pickle_pv" {
  metadata {
    name = "cwl-pickle-pv"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.cwl_pickle_folder
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "cwl_pickle_pvc" {
  metadata {
    name      = "cwl-pickle-pvc"
    namespace = "unity-sps"
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.cwl_pickle_pv.metadata[0].name
  }
}


resource "kubernetes_deployment" "scheduler" {
  metadata {
    name      = "scheduler"
    namespace = "unity-sps"
    labels = {
      app = "scheduler"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "scheduler"
      }
    }
    template {
      metadata {
        labels = {
          app = "scheduler"
        }
      }
      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "unity-dev-sps-EKS-VerdiNodeGroup"
        }
        container {
          name              = "dind-daemon"
          image             = var.docker_images.dind
          image_pull_policy = "Always"
          env {
            name  = "DOCKER_TLS_CERTDIR"
            value = ""
          }
          resources {
            requests = {
              cpu    = "20m"
              memory = "512Mi"
            }
          }
          security_context {
            privileged = true
          }
          args = ["--tls=false"]
          lifecycle {
            post_start {
              exec {
                # Note: must wait a few seconds for the Docker engine to start and the file to be created
                command = [
                  "bin/sh",
                  "-c",
                  <<-EOT
                  sleep 5 && \
                  chmod 777 /var/run/docker.sock
                  EOT
                ]
              }
            }
          }
          # Empty directory where the Docker engine indices the images
          volume_mount {
            name       = "docker-graph-storage"
            mount_path = "/var/lib/docker"
          }
          # The Docker socket must be shared with Verdi container
          volume_mount {
            name       = "docker-sock-dir"
            mount_path = "/var/run"
            sub_path   = "docker.sock"
          }
        }
        container {
          image             = var.docker_images.airflow_cwl
          image_pull_policy = "IfNotPresent"
          name              = "scheduler"
          args              = ["start_scheduler.sh"]
          security_context {
            privileged = true
          }
          volume_mount {
            mount_path = var.airflow_home
            name       = "airflow-home"
          }
          volume_mount {
            mount_path = var.cwl_tmp_folder
            name       = "cwl-tmp"
          }
          volume_mount {
            mount_path = var.cwl_inputs_folder
            name       = "cwl-inputs"
          }
          volume_mount {
            mount_path = var.cwl_outputs_folder
            name       = "cwl-outputs"
          }
          volume_mount {
            mount_path = var.cwl_pickle_folder
            name       = "cwl-pickle"
          }
          volume_mount {
            name       = "docker-sock-dir"
            mount_path = "/var/run"
            sub_path   = "docker.sock"
          }
          env {
            name  = "AIRFLOW_HOME"
            value = var.airflow_home
          }
          env {
            name  = "PROCESS_REPORT_URL"
            value = var.process_report_url
          }
          env {
            name  = "AIRFLOW__CORE__EXECUTOR"
            value = "LocalExecutor"
          }
          env {
            name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value = "mysql://${var.mysql_user}:${var.mysql_password}@mysql:3306/${var.mysql_database}"
          }
          env {
            name  = "AIRFLOW__CORE__DAGS_FOLDER"
            value = "${var.airflow_home}/dags"
          }
          env {
            name  = "AIRFLOW__CORE__BASE_LOG_FOLDER"
            value = "${var.airflow_home}/logs"
          }
          env {
            name  = "AIRFLOW__CORE__DAG_PROCESSOR_MANAGER_LOG_LOCATION"
            value = "${var.airflow_home}/logs/dag_processor_manager/dag_processor_manager.log"
          }
          env {
            name  = "AIRFLOW__CORE__PLUGINS_FOLDER"
            value = "${var.airflow_home}/plugins"
          }
          env {
            name  = "AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY"
            value = "${var.airflow_home}/logs/scheduler"
          }
        }
        volume {
          name = "airflow-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.airflow_home_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-tmp"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_tmp_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-inputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_inputs_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-outputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_outputs_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-pickle"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_pickle_pvc.metadata[0].name
          }
        }
        # Shared direcrtory holding the Docker socket
        volume {
          name = "docker-sock-dir"
          empty_dir {}
        }
        # Clean Docker storage
        volume {
          name = "docker-graph-storage"
          empty_dir {}
        }
        restart_policy = "Always"
      }
    }
  }
  depends_on = [kubernetes_service.mysql]
}

resource "kubernetes_persistent_volume" "mysql_data_pv" {
  metadata {
    name = "mysql-data-pv"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = var.mysql_data_folder
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "mysql_data_pvc" {
  metadata {
    name      = "mysql-data-pvc"
    namespace = "unity-sps"
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.mysql_data_pv.metadata[0].name
  }
}


resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "unity-sps"
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "unity-dev-sps-EKS-VerdiNodeGroup"
        }
        container {
          image = var.docker_images.mysql
          name  = "mysql"
          args  = ["--explicit-defaults-for-timestamp=1"]

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }
          env {
            name  = "MYSQL_DATABASE"
            value = var.mysql_database
          }
          env {
            name  = "MYSQL_USER"
            value = var.mysql_user
          }
          env {
            name  = "MYSQL_PASSWORD"
            value = var.mysql_password
          }

          volume_mount {
            mount_path = "/var/lib/mysql"
            name       = "mysql-data"
          }
        }

        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_data_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "unity-sps"
  }
  spec {
    selector = {
      app = "mysql"
    }
    port {
      port        = var.service_port_map.mysql_service
      target_port = var.service_port_map.mysql_service
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "webserver" {
  metadata {
    name      = "webserver"
    namespace = "unity-sps"
    labels = {
      app = "webserver"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "webserver"
      }
    }
    template {
      metadata {
        labels = {
          app = "webserver"
        }
      }
      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "unity-dev-sps-EKS-VerdiNodeGroup"
        }
        container {
          image             = var.docker_images.airflow_cwl
          image_pull_policy = "IfNotPresent"
          name              = "webserver"
          args              = ["start_webserver.sh"]
          security_context {
            privileged = true
          }
          volume_mount {
            mount_path = var.airflow_home
            name       = "airflow-home"
          }
          volume_mount {
            mount_path = var.cwl_tmp_folder
            name       = "cwl-tmp"
          }
          volume_mount {
            mount_path = var.cwl_inputs_folder
            name       = "cwl-inputs"
          }
          volume_mount {
            mount_path = var.cwl_outputs_folder
            name       = "cwl-outputs"
          }
          volume_mount {
            mount_path = var.cwl_pickle_folder
            name       = "cwl-pickle"
          }
          env {
            name  = "AIRFLOW_HOME"
            value = var.airflow_home
          }
          env {
            name  = "PROCESS_REPORT_URL"
            value = var.process_report_url
          }
          env {
            name  = "AIRFLOW__CORE__EXECUTOR"
            value = "LocalExecutor"
          }
          env {
            name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value = "mysql://${var.mysql_user}:${var.mysql_password}@mysql:3306/${var.mysql_database}"
          }
          env {
            name  = "AIRFLOW__CORE__DAGS_FOLDER"
            value = "${var.airflow_home}/dags"
          }
          env {
            name  = "AIRFLOW__CORE__BASE_LOG_FOLDER"
            value = "${var.airflow_home}/logs"
          }
          env {
            name  = "AIRFLOW__CORE__DAG_PROCESSOR_MANAGER_LOG_LOCATION"
            value = "${var.airflow_home}/logs/dag_processor_manager/dag_processor_manager.log"
          }
          env {
            name  = "AIRFLOW__CORE__PLUGINS_FOLDER"
            value = "${var.airflow_home}/plugins"
          }
          env {
            name  = "AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY"
            value = "${var.airflow_home}/logs/scheduler"
          }
        }
        volume {
          name = "airflow-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.airflow_home_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-tmp"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_tmp_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-inputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_inputs_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-outputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_outputs_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-pickle"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_pickle_pvc.metadata[0].name
          }
        }
        restart_policy = "Always"
      }
    }
  }
  depends_on = [kubernetes_service.mysql, kubernetes_deployment.scheduler]
}

resource "kubernetes_service" "webserver" {
  metadata {
    name      = "webserver"
    namespace = "unity-sps"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnets
    }
  }
  spec {
    selector = {
      app = "webserver"
    }
    type = var.service_type
    port {
      protocol    = "TCP"
      port        = var.service_port_map.airflow_cwl_webserver_service
      target_port = 8080
    }
    # port {
    #   port        = 8080
    #   target_port = 8080
    #   node_port   = 30080
    # }
    # type = "NodePort"
  }
}


resource "kubernetes_deployment" "apiserver" {
  metadata {
    name      = "apiserver"
    namespace = "unity-sps"
    labels = {
      app = "apiserver"
    }
  }
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "apiserver"
      }
    }
    template {
      metadata {
        labels = {
          app = "apiserver"
        }
      }
      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = "unity-dev-sps-EKS-VerdiNodeGroup"
        }
        container {
          image             = var.docker_images.airflow_cwl
          image_pull_policy = "IfNotPresent"
          name              = "apiserver"
          args              = ["start_apiserver.sh", "--replay", "60", "--host", "0.0.0.0"]
          security_context {
            privileged = true
          }
          volume_mount {
            mount_path = var.airflow_home
            name       = "airflow-home"
          }
          volume_mount {
            mount_path = var.cwl_tmp_folder
            name       = "cwl-tmp"
          }
          volume_mount {
            mount_path = var.cwl_inputs_folder
            name       = "cwl-inputs"
          }
          volume_mount {
            mount_path = var.cwl_outputs_folder
            name       = "cwl-outputs"
          }
          volume_mount {
            mount_path = var.cwl_pickle_folder
            name       = "cwl-pickle"
          }
          env {
            name  = "AIRFLOW_HOME"
            value = var.airflow_home
          }
          env {
            name  = "PROCESS_REPORT_URL"
            value = var.process_report_url
          }
          env {
            name  = "AIRFLOW__CORE__EXECUTOR"
            value = "LocalExecutor"
          }
          env {
            name  = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
            value = "mysql://${var.mysql_user}:${var.mysql_password}@mysql:3306/${var.mysql_database}"
          }
          env {
            name  = "AIRFLOW__CORE__DAGS_FOLDER"
            value = "${var.airflow_home}/dags"
          }
          env {
            name  = "AIRFLOW__CORE__BASE_LOG_FOLDER"
            value = "${var.airflow_home}/logs"
          }
          env {
            name  = "AIRFLOW__CORE__DAG_PROCESSOR_MANAGER_LOG_LOCATION"
            value = "${var.airflow_home}/logs/dag_processor_manager/dag_processor_manager.log"
          }
          env {
            name  = "AIRFLOW__CORE__PLUGINS_FOLDER"
            value = "${var.airflow_home}/plugins"
          }
          env {
            name  = "AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY"
            value = "${var.airflow_home}/logs/scheduler"
          }
        }
        volume {
          name = "airflow-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.airflow_home_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-tmp"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_tmp_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-inputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_inputs_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-outputs"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_outputs_pvc.metadata[0].name
          }
        }
        volume {
          name = "cwl-pickle"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.cwl_pickle_pvc.metadata[0].name
          }
        }
        restart_policy = "Always"
      }
    }
  }
  depends_on = [kubernetes_service.mysql, kubernetes_deployment.scheduler]
}

resource "kubernetes_service" "apiserver" {
  metadata {
    name      = "apiserver"
    namespace = "unity-sps"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnets
    }
  }
  spec {
    selector = {
      app = "apiserver"
    }
    # type = "NodePort"
    # port {
    #   port        = 8081
    #   target_port = 8081
    #   node_port   = 30081
    # }
    type = var.service_type
    port {
      protocol    = "TCP"
      port        = var.service_port_map.airflow_cwl_apiserver_service
      target_port = 8081
    }
  }
}
