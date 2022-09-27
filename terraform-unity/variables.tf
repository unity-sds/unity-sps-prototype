variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
}

variable "venue" {
  description = "The MCP venue in which the cluster will be deployed (dev, test, prod)"
  type        = string
}

variable "counter" {
  description = "value"
  type        = number
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "docker_images" {
  description = "Docker images for the Unity SPS containers"
  type        = map(string)
  default = {
    hysds_core     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1"
    hysds_ui       = "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1"
    hysds_mozart   = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1"
    hysds_grq2     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1"
    hysds_verdi    = "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1"
    hysds_factotum = "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1"
    ades_wpst_api  = "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1"
    logstash       = "docker.elastic.co/logstash/logstash:7.10.2"
    minio          = "minio/minio:RELEASE.2022-03-17T06-34-49Z"
    mc             = "minio/mc:RELEASE.2022-03-13T22-34-00Z"
    rabbitmq       = "rabbitmq:3-management"
    busybox        = "k8s.gcr.io/busybox"
    redis          = "redis:latest"
  }
}

variable "mozart_es" {
  description = "value"
  type = object({
    volume_claim_template = object({
      storage_class_name = string
    })
  })
  default = {
    volume_claim_template = {
      storage_class_name = "gp2-sps"
    }
  }
}


variable "service_type" {
  description = "value"
  type        = string
  default     = "LoadBalancer"
}

variable "node_port_map" {
  description = "value"
  type        = map(number)
  default = {
    "mozart_service"          = 30001
    "grq2_service"            = 30002
    "minio_service_api"       = 30007
    "minio_service_interface" = 30008
    "hysds_ui_service"        = 30009
    "ades_wpst_api_service"   = 30011
    "grq2_es"                 = 30012
    "mozart_es"               = 30013
  }
}

variable "datasets_filename" {
  description = "value"
  type        = string
  default     = "datasets.remote.template.json"
}

variable "celeryconfig_filename" {
  description = "value"
  type        = string
  default     = "celeryconfig_remote.py"
}

variable "deployment_environment" {
  description = "value"
  type        = string
  default     = "mcp"
}
