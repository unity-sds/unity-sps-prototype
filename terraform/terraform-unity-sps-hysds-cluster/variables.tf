variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
  default     = "unity-sps"
}

variable "container_registry_server" {
  description = "Container registry server"
  type        = string
}

variable "container_registry_username" {
  description = "Container registry username"
  type        = string
}
variable "container_registry_password" {
  description = "Container registry password"
  type        = string
}

variable "hysds_core_image" {
  description = "Docker image for the HySDS Core container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1"
}

variable "hysds_ui_image" {
  description = "Docker image for the HySDS UI container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui:unity-v0.0.1"
}

variable "hysds_mozart_image" {
  description = "Docker image for the HySDS Mozart container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1"
}

variable "hysds_grq2_image" {
  description = "Docker image for the HySDS GRQ2 container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1"
}

variable "hysds_verdi_image" {
  description = "Docker image for the HySDS Verdi container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1"
}

variable "ades_wpst_api_image" {
  description = "Docker image for the ADES WPST Flask API container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1"
}

variable "hysds_factotum_image" {
  description = "Docker image for the HySDS Factotum container"
  type        = string
  default     = "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1"
}

# Bump version from 7.9.3 to 7.10.2 in order to provide support for Apple M1
# https://stackoverflow.com/questions/65962810/m1-mac-issue-bringing-up-elasticsearch-cannot-run-jdk-bin-java
variable "logstash_image" {
  description = "Docker image for the Logstash container"
  type        = string
  default     = "docker.elastic.co/logstash/logstash:7.10.2"
}

variable "minio_image" {
  description = "Docker image for the MinIO container"
  type        = string
  default     = "minio/minio:RELEASE.2022-03-17T06-34-49Z"

}

variable "mc_image" {
  description = "Docker image for the MinIO client container"
  type        = string
  default     = "minio/mc:RELEASE.2022-03-13T22-34-00Z"
}

variable "rabbitmq_image" {
  description = "Docker image for the RabbitMQ container"
  type        = string
  default     = "rabbitmq:3-management"
}

variable "busybox_image" {
  description = "Docker image for the Busybox container"
  type        = string
  default     = "k8s.gcr.io/busybox"
}
variable "redis_image" {
  description = "Docker image for the Redis container"
  type        = string
  default     = "redis:latest"
}
