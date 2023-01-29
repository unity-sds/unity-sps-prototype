provider "kubernetes" {
  config_path = var.kubeconfig_filepath
  insecure    = true
}

data "aws_eks_cluster" "sps-cluster" {
  name = "u-sps-dev-prototype-cluster"
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
