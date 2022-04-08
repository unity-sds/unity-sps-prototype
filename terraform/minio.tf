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
    type             = "LoadBalancer"
    session_affinity = "ClientIP"
    port {
      name        = "minio-api"
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }
    port {
      name     = "minio-interface"
      port     = 9001
      protocol = "TCP"
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
          image = "minio/minio:RELEASE.2022-03-17T06-34-49Z"
          name  = "minio"
          args  = ["server", "/storage", "--console-address=:9001"]
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
            claim_name = "minio-pv-claim"
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
          image   = "minio/mc:RELEASE.2022-03-13T22-34-00Z"
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
             while [ $$(curl -sw '%%{http_code}' "http://minio:9000/minio/health/live" -o /dev/null) -ne 200 ]; do
               echo "Waiting for minio server to be ready..." && sleep 5;
             done
             mc alias set s3 http://minio:9000 hysds password;
             mc mb s3/datasets;
             mc policy set public s3/datasets;
             EOT
          ]
        }
        container {
          name    = "publish-aoi"
          image   = "hysds-core:unity-v0.0.1"
          command = ["/bin/sh"]
          args    = ["-c", "cd /home/ops/hysds/test/examples;", "/home/ops/hysds/scripts/ingest_dataset.py AOI_sacramento_valley /home/ops/datasets.json;"]
          volume_mount {
            name       = "celeryconfig"
            mount_path = "/home/ops/hysds/celeryconfig.py"
            sub_path   = "celeryconfig.py"
            read_only  = false
          }
          volume_mount {
            name       = "aws-credentials"
            mount_path = "/home/ops/.aws/credentials"
            sub_path   = "aws-credentials"
            read_only  = false
          }
          volume_mount {
            name       = "datasets"
            mount_path = "/home/ops/datasets.json"
            sub_path   = "datasets.json"
            read_only  = false
          }
        }
        volume {
          name = "celeryconfig"
          config_map {
            name = "celeryconfig"
          }
        }
        volume {
          name = "aws-credentials"
          config_map {
            name = "aws-credentials"
          }
        }
        volume {
          name = "datasets"
          config_map {
            name = "datasets"
          }
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}
