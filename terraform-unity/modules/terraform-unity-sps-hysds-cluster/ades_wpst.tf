resource "kubernetes_persistent_volume" "ades-wpst-sqlite-pv" {
  metadata {
    name = "ades-wpst-sqlite-pv"
  }

  spec {
    storage_class_name = "gp2"
    access_modes       = ["ReadWriteOnce"]
    capacity = {
      storage = "20Gi"
    }

    persistent_volume_reclaim_policy = "Delete"

    persistent_volume_source {
      host_path {
        path = "/flask_ades_wpst/sqlite"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "ades-wpst-sqlite-pv-claim" {
  metadata {
    name      = "ades-wpst-sqlite-pv-claim"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "ades-wpst-sqlite-storage-claim"
    }
  }

  spec {
    storage_class_name = "gp2"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.ades-wpst-sqlite-pv.metadata[0].name
  }
}

resource "kubernetes_service" "ades-wpst-api-service" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-name" = "${var.project}-${var.venue}-${var.service_area}-adeswpst-RestApiLoadBalancer-${local.counter}"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = join(",", [for k, v in merge(local.common_tags, {
        "Name"      = "${var.project}-${var.venue}-${var.service_area}-adeswpst-RestApiLoadBalancer-${local.counter}"
        "Component" = "adeswpst"
        "Stack"     = "adeswpst"
      }) : format("%s=%s", k, v)])
      "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnets
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = var.lb_scheme
      "service.beta.kubernetes.io/aws-load-balancer-internal" = var.legacy_lb_internal
    }
  }
  spec {
    selector = {
      app = "ades-wpst-api"
    }
    # type = "NodePort"
    type = var.service_type
    port {
      protocol    = "TCP"
      port        = var.service_port_map.ades_wpst_api_service
      target_port = 5000
      # node_port   = 32000
    }
  }
}

resource "kubernetes_deployment" "ades-wpst-api" {
  metadata {
    name      = "ades-wpst-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "ades-wpst-api"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "ades-wpst-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "ades-wpst-api"
        }
      }
      spec {
        node_selector = {
          "eks.amazonaws.com/nodegroup" = var.default_group_node_group_name
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
                  chmod 777 /var/run/docker.sock && \
                  docker pull ${var.docker_images.sps_hysds_pge_base}
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
          image             = var.docker_images.ades_wpst_api
          image_pull_policy = "Always"
          name              = "ades-wpst-api"
          lifecycle {
            # TODO remove, this is a temp workaround
            post_start {
              exec {
                command = [
                  "/bin/sh",
                  "-c",
                  <<-EOT
                  cd / && \
                  git clone https://github.com/unity-sds/unity-sps-register_job.git && \
                  git clone -b  v1.0.5 https://github.com/hysds/lightweight-jobs.git && \
                  python3 /flask_ades_wpst/utils/register_lightweight_jobs.py --image-name lightweight-jobs --image-tag v1.0.5 --register-job-location /lightweight-jobs
                  EOT
                ]
              }
            }
          }
          env {
            name  = "ADES_PLATFORM"
            value = "HYSDS"
          }
          env {
            name  = "CR_SERVER"
            value = var.container_registry_server
          }
          env {
            name  = "CR_USERNAME"
            value = var.container_registry_username
          }
          env {
            name  = "CR_PAT"
            value = var.container_registry_pat
          }
          env {
            name  = "CR_OWNER"
            value = var.container_registry_owner
          }
          env {
            name  = "STAGING_BUCKET"
            value = var.uds_staging_bucket
          }
          env {
            name  = "CLIENT_ID"
            value = var.uds_client_id
          }
          env {
            name  = "DAPA_API"
            value = var.uds_dapa_api
          }
          env {
            name  = "DOCKER_HOST"
            value = "tcp://localhost:2375"
          }
          env {
            name  = "JOBS_DATA_SNS_TOPIC_ARN"
            value = aws_sns_topic.jobs_data.arn
          }
          env {
            name  = "JOBS_DB_URL"
            value = "http://${data.kubernetes_service.jobs-es.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.jobs_es}"
          }
          port {
            container_port = 5000
          }
          volume_mount {
            name       = "sqlite-db"
            mount_path = "/flask_ades_wpst/sqlite"
          }
          # The Docker socket use to communicate with the Docker engine
          volume_mount {
            name       = "docker-sock-dir"
            mount_path = "/var/run"
            sub_path   = "docker.sock"
          }
        }
        volume {
          name = "sqlite-db"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim.metadata[0].name
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
  depends_on = [
    kubernetes_service.mozart-service,
    kubernetes_service.grq2-service,
    data.kubernetes_service.mozart-es,
    data.kubernetes_service.grq-es
  ]
}
