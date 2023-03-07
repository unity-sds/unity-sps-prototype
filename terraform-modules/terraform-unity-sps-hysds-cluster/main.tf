data "aws_eks_cluster" "sps-cluster" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  config_path = var.kubeconfig_filepath
  insecure    = true
}

resource "kubernetes_namespace" "unity-sps" {
  metadata {
    name = var.namespace
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_filepath
    insecure    = true
  }
}

provider "aws" {
  region = "us-west-2"
}
