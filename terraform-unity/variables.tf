variable "project" {
  description = "The project or mission deploying Unity SPS"
  type        = string
  default     = null
}

variable "service_area" {
  description = "The service area owner of the resources being deployed"
  type        = string
  default     = "sps"
}

variable "deployment_name" {
  description = "Unique name of this deployment in the account."
  type        = string
}

variable "venue" {
  description = "The MCP venue in which the cluster will be deployed (dev, test, prod)"
  type        = string
  default     = null
}

variable "release" {
  description = "The SPS release version"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
  default     = "../k8s/kubernetes.yml"
}

variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
  default     = "unity-sps"
}

variable "counter" {
  description = "value"
  type        = string
  default     = ""
}

variable "docker_images" {
  description = "Docker images for the Unity SPS containers"
  type        = map(string)
  default = {
    hysds_core         = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v1.1.0"
    hysds_ui           = "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v1.1.0"
    hysds_mozart       = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v1.1.0"
    hysds_grq2         = "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v1.1.0"
    hysds_verdi        = "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v1.1.0"
    hysds_factotum     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v1.1.0"
    ades_wpst_api      = "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:develop"
    sps_api            = "ghcr.io/unity-sds/unity-sps-prototype/sps-api:unity-v1.1.0"
    sps_hysds_pge_base = "ghcr.io/unity-sds/unity-sps-prototype/sps-hysds-pge-base:develop"
    logstash           = "docker.elastic.co/logstash/logstash:7.10.2"
    rabbitmq           = "rabbitmq:3.11.13-management"
    busybox            = "busybox:1.36.0"
    redis              = "redis:7.0.10"
    dind               = "docker:23.0.3-dind"
  }
}

variable "service_type" {
  description = "value"
  type        = string
  default     = "LoadBalancer"
}

variable "service_port_map" {
  description = "value"
  type        = map(number)
  default = {
    "mozart_service"                    = 8888
    "grq2_service"                      = 8878
    "rabbitmq_mgmt_service_cluster_rpc" = 15672
    "rabbitmq_service_epmd"             = 4369
    "rabbitmq_service_listener"         = 5672
    "rabbitmq_service_cluster_rpc"      = 15672
    "hysds_ui_service"                  = 3000
    "redis_service"                     = 6379
    "ades_wpst_api_service"             = 5001
    "sps_api_service"                   = 5002
    "grq2_es"                           = 9201
    "mozart_es"                         = 9200
    "jobs_es"                           = 9202
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

variable "container_registry_server" {
  description = "value"
  type        = string
  default     = "ghcr.io"
}

variable "container_registry_username" {
  description = "value"
  type        = string
  default     = "drewm-jpl"
}

variable "container_registry_owner" {
  description = "value"
  type        = string
  default     = "unity-sds/unity-sps-prototype"
}

variable "uads_development_efs_fsmt_id" {
  description = "value"
  type        = string
  default     = null
}

variable "elb_subnets" {
  description = "value"
  type        = string
  default     = null
}

variable "default_group_node_group_name" {
  description = "value"
  type        = string
  default     = null
}

variable "verdi_node_group_capacity_type" {
  description = "value"
  type        = string
  default     = "ON_DEMAND"
}

variable "verdi_node_group_scaling_config" {
  description = "value"
  type        = map(number)
  default = {
    "desired_size" = 3
    "min_size"     = 0
    "max_size"     = 10
  }
}

variable "verdi_node_group_instance_types" {
  description = "value"
  type        = list(string)
  default     = ["m3.medium"]
}

variable "add_routes_to_api_gateway" {
  description = "If true, adds routes to api gateway configured in account"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Applicable extra tags"
  type = map(string)
  default = {}
}
