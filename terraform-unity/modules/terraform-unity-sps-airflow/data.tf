data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster_vpc.id]
  }

  tags = {
    "Tier" = "Public"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster_vpc.id]
  }

  tags = {
    "Tier" = "Private"
  }
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

data "kubernetes_ingress_v1" "airflow_ingress" {
  metadata {
    name      = kubernetes_ingress_v1.airflow_ingress.metadata[0].name
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }
  depends_on = [time_sleep.wait_for_lb]
}
