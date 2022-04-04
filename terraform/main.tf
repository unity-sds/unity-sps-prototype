provider "kubernetes" {
  config_path = "~/.kube/config"
  insecure    = true
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    insecure    = true
  }
}

resource "kubernetes_namespace" "unity-sps" {
  metadata {
    name = var.namespace
  }
}
