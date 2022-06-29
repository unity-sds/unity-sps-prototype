resource "kubernetes_persistent_volume_claim" "minio-pv-claim" {
  metadata {
    name      = "minio-pv-claim"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "minio-storage-claim"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}


resource "kubernetes_service" "minio_service" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }

  spec {
    type = var.service_type
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    port {
      name        = "minio-api"
      protocol    = "TCP"
      port        = 9000
      target_port = 9000
      node_port   = var.service_type != "NodePort" ? null : var.node_port_map.minio_service_api
    }
    port {
      name      = "minio-interface"
      protocol  = "TCP"
      port      = 9001
      node_port = var.service_type != "NodePort" ? null : var.node_port_map.minio_service_interface
    }
    selector = {
      app = "minio"
    }
  }
}


resource "kubernetes_deployment" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
    labels = {
      app = "minio"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "minio"
      }
    }
    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "minio"
        }
      }

      spec {
        container {
          image = var.docker_images.minio
          name  = "minio"
          # security_context {
          #   run_as_non_root = true
          # }
          # Run as non-root user
          # https://docs.min.io/docs/minio-docker-quickstart-guide
          args = ["server", "/storage", "--console-address=:9001"]
          env {
            name  = "MINIO_ACCESS_KEY"
            value = "hysds"
          }
          env {
            name  = "MINIO_SECRET_KEY"
            value = "password"
          }
          port {
            container_port = 9000
            host_port      = 9000
          }
          port {
            container_port = 9001
            host_port      = 9001
          }
          volume_mount {
            name       = "storage"
            mount_path = "/storage"
            read_only  = false
          }

        }

        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.minio-pv-claim.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_job" "mc" {
  metadata {
    name      = "mc"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  spec {
    template {
      metadata {}
      spec {
        init_container {
          name    = "minio-setup"
          image   = var.docker_images.mc
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            until curl -s -I http://minio:9000; do echo "(Minio server) waiting..."; sleep 2; done;
            until curl -s -I http://minio:9001; do echo "(Minio client) waiting..."; sleep 2; done;
            while [ $$(curl -sw '%%{http_code}' "http://minio:9000/minio/health/live" -o /dev/null) -ne 200 ]; do
              echo "Waiting for minio health live to be ready..." && sleep 5;
            done;
            mc alias set s3 http://minio:9000 hysds password;
            mc mb s3/datasets;
            mc policy set public s3/datasets;
            EOT
          ]
        }
        container {
          name    = "publish-aoi"
          image   = var.docker_images.hysds_core
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            set -x;

            curl -XGET "http://grq-es:9201/_cluster/health?pretty=true&wait_for_status=yellow&timeout=30s";
            while [ $$(curl -ILs http://grq2:8878/api/v0.1/doc | tac | grep -m1 HTTP/1.1 | awk {'print $2'}) -ne 200 ]; do
              echo "Waiting for GRQ2 to be ready..." && sleep 5;
            done;

            while [ $$(curl -sw '%%{http_code}' "http://grq-es:9201" -o /dev/null) -ne 200 ]; do
              echo "Waiting for grq-es to be ready..." && sleep 5;
            done;

            curl -XGET "http://mozart-es:9200/_cluster/health?pretty=true&wait_for_status=yellow&timeout=30s";
            while [ $$(curl -ILs http://mozart:8888/api/v0.1/doc | tac | grep -m1 HTTP/1.1 | awk {'print $2'}) -ne 200 ]; do
              echo "Waiting for mozart to be ready..." && sleep 5;
            done;

            while [ $$(curl -sw '%%{http_code}' "http://mozart-es:9200" -o /dev/null) -ne 200 ]; do
              echo "Waiting for mozart-es to be ready..." && sleep 5;
            done;

            cd /home/ops/hysds/test/examples;
            /home/ops/hysds/scripts/ingest_dataset.py AOI_sacramento_valley /home/ops/datasets.json;
            EOT
          ]
          volume_mount {
            name       = kubernetes_config_map.celeryconfig.metadata.0.name
            mount_path = "/home/ops/hysds/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }
          volume_mount {
            name       = kubernetes_config_map.aws-credentials.metadata.0.name
            mount_path = "/home/ops/.aws/credentials"
            sub_path   = "aws-credentials"
            read_only  = false
          }
          volume_mount {
            name       = kubernetes_config_map.datasets.metadata.0.name
            mount_path = "/home/ops/datasets.json"
            sub_path   = "datasets.json"
            read_only  = false
          }
        }
        volume {
          name = kubernetes_config_map.celeryconfig.metadata.0.name
          config_map {
            name = kubernetes_config_map.celeryconfig.metadata.0.name
          }
        }
        volume {
          name = kubernetes_config_map.aws-credentials.metadata.0.name
          config_map {
            name = kubernetes_config_map.aws-credentials.metadata.0.name
          }
        }
        volume {
          name = kubernetes_config_map.datasets.metadata.0.name
          config_map {
            name = kubernetes_config_map.datasets.metadata.0.name
          }
        }
        restart_policy = "Never"
      }
    }
  }
  depends_on = [
    kubernetes_deployment.grq2,
    kubernetes_deployment.mozart,
    helm_release.grq2-es,
    helm_release.mozart-es,
  ]
  wait_for_completion = true
  timeouts {
    create = "5m"
    update = "5m"
  }
}
