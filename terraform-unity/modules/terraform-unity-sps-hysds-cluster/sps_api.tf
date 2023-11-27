resource "kubernetes_service" "sps-api-service" {
  metadata {
    name      = "sps-api"
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
  }
  spec {
    selector = {
      app = "sps-api"
    }
    type = "NodePort"
    port {
      protocol    = "TCP"
      port        = var.service_port_map.sps_api_service
      target_port = 80
    }
  }
}

resource "aws_ssm_parameter" "sps-api-hostname-param" {
  name        = "/unity/sps/${var.deployment_name}/spsApi/url"
  description = "Hostname of sps api load balancer"
  type        = "String"
  value       = "http://${aws_lb.sps-api-load-balancer.dns_name}:${var.service_port_map.sps_api_service}"
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
        node_selector = {
          "eks.amazonaws.com/nodegroup" = aws_eks_node_group.sps_api.node_group_name
        }
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
            value = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroup"
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
