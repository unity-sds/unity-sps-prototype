data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

data "kubernetes_service" "airflow_webserver" {
  metadata {
    name      = "airflow-webserver"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }

  depends_on = [
    helm_release.airflow
  ]
}

data "aws_ssm_parameter" "eks_private_subnets" {
  count = var.elb_subnets == null ? 1 : 0
  name  = "/unity/extensions/eks/${var.eks_cluster_name}/networking/subnets/publicIds"
}
