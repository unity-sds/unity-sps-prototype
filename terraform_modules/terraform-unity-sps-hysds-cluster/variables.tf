variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
  default     = "unity-sps"
}

variable "container_registry" {
  type = object({
    server   = string
    username = string
    password = string
  })
}

variable "docker_images" {
  type = map(string)
  default = {
    hysds_core   = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1"
    hysds_mozart = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1"
  }
}

variable "mozart_es" {
  type = object({
    volume_claim_template = object({
      storage_class_name = string
    })
  })
  default = {
    volume_claim_template = {
      storage_class_name = "microk8s-hostpath"
    }
  }
}

variable "service_type" {
  type    = string
  default = "NodePort"
}


variable "node_port_map" {
  type = map(number)
  default = {
    "mozart_service" = 30001
    "mozart_es"      = 30013
  }
}

variable "celeryconfig_filename" {
  type    = string
  default = "celeryconfig_remote.py"
}
