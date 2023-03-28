variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "eks_cluster_name" {
  description = "value"
  type        = string
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "project" {
  description = "The project or mission deploying Unity SPS"
  type        = string
  default     = "unity"
}

variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
  default     = "unity-sps"
}

variable "venue" {
  description = "The MCP venue in which the cluster will be deployed (dev, test, prod)"
  type        = string
}

variable "service_area" {
  description = "The service area owner of the resources being deployed"
  type        = string
  default     = "sps"
}

variable "counter" {
  description = "value"
  type        = number
}

variable "docker_images" {
  description = "Docker images for the Unity SPS containers"
  type        = map(string)
  default = {
    hysds_core         = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1"
    hysds_ui           = "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1"
    hysds_mozart       = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1"
    hysds_grq2         = "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1"
    hysds_verdi        = "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1"
    hysds_factotum     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1"
    ades_wpst_api      = "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1"
    sps_api            = "ghcr.io/unity-sds/unity-sps-prototype/sps-api:unity-v0.0.1"
    sps_hysds_pge_base = "ghcr.io/unity-sds/unity-sps-prototype/sps-hysds-pge-base:unity-v0.0.1"
    logstash           = "docker.elastic.co/logstash/logstash:7.10.2"
    rabbitmq           = "rabbitmq:3-management"
    busybox            = "k8s.gcr.io/busybox"
    redis              = "redis:latest"
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

variable "container_registry_server" {
  description = "value"
  type        = string
}

variable "container_registry_username" {
  description = "value"
  type        = string
}

variable "container_registry_pat" {
  description = "value"
  type        = string
}

variable "container_registry_owner" {
  description = "value"
  type        = string
}

variable "uds_staging_bucket" {
  description = "value"
  type        = string
}

variable "uds_client_id" {
  description = "value"
  type        = string
}

variable "uds_dapa_api" {
  description = "value"
  type        = string
}

variable "uads_development_efs_fsmt_id" {
  description = "value"
  type        = string
  default     = null
}


variable "elb_subnet" {
  description = "value"
  type        = string
}

# TODO - Consolidate these verdi variables

variable "default_group_node_group_name" {
  description = "value"
  type        = string
  default     = "defaultgroupNodeGroup"
}


variable "default_group_node_group_launch_template_name" {
  description = "value"
  type        = string
  default     = "eksctl-unity-test-sps-hysds-eks-multinode-nodegroup-defaultgroupNodeGroup"
}


variable "verdi_node_group_name" {
  description = "value"
  type        = string
  default     = "VerdiNodeGroup"
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
    "desired_size" = 1
    "min_size"     = 0
    "max_size"     = 10
  }
}


variable "verdi_node_group_instance_types" {
  description = "value"
  type        = list(string)
  default     = ["m3.medium"]
}
