provider "kubernetes" {
  config_path = "./kubeconfig.yaml"
  insecure    = true
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig.yaml"
    insecure    = true
  }
}

resource "kubernetes_namespace" "unity-sps" {
  metadata {
    name = var.namespace
  }
}
