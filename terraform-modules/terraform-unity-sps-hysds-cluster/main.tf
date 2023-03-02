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

# resource "random_id" "counter" {
#   byte_length = 2
# }

# locals {
#   counter = var.counter != "" ? var.counter : random_id.counter.hex
# }
