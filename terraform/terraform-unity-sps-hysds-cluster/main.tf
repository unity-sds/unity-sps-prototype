provider "kubernetes" {
  config_path = var.kubeconfig_filepath
  insecure    = true
}

resource "kubernetes_namespace" "unity-sps" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "container-registry" {
  metadata {
    name      = "container-registry"
    namespace = kubernetes_namespace.unity-sps.metadata.0.name
  }
  data = {
    ".dockerconfigjson" = var.base64_encoded_dockerconfig
  }
  type = "kubernetes.io/dockerconfigjson"
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_filepath
    insecure    = true
  }
}
