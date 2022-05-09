variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
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
