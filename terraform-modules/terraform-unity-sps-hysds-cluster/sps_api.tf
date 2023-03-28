resource "kubernetes_service" "sps-api-service" {
  metadata {
    name      = "sps-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-subnets" = var.elb_subnet
    }
  }
  spec {
    selector = {
      app = "sps-api"
    }
    session_affinity = var.deployment_environment != "local" ? null : "ClientIP"
    type             = var.service_type
    port {
      protocol    = "TCP"
      port        = var.service_port_map.sps_api_service
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "sps-api" {
  metadata {
    name      = "sps-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    labels = {
      app = "sps-api"
    }
  }

  spec {
    # replicas = 2
    selector {
      match_labels = {
        app = "sps-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "sps-api"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.sps-api.metadata[0].name
        container {
          image             = var.docker_images.sps_api
          image_pull_policy = "Always"
          name              = "sps-api"
          port {
            container_port = 80
          }
          env {
            name  = "AWS_REGION_NAME"
            value = var.region
          }
          env {
            name  = "EKS_CLUSTER_NAME"
            value = var.eks_cluster_name
          }
          env {
            name  = "VERDI_NODE_GROUP_NAME"
            value = "VerdiNodeGroup"
          }
          env {
            name  = "VERDI_DAEMONSET_NAMESPACE"
            value = kubernetes_daemonset.verdi.metadata[0].namespace
          }
          env {
            name  = "VERDI_DAEMONSET_NAME"
            value = kubernetes_daemonset.verdi.metadata[0].name
          }
        }
        restart_policy = "Always"
      }
    }
  }
}
