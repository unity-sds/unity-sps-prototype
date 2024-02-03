variable "project" {
  description = "The project or mission deploying Unity SPS"
  type        = string
  default     = "unity"
}

variable "service_area" {
  description = "The service area owner of the resources being deployed"
  type        = string
  default     = "sps"
}

variable "venue" {
  description = "The MCP venue in which the cluster will be deployed (dev, test, prod)"
  type        = string
}

variable "counter" {
  description = "value"
  type        = string
  default     = ""
}

variable "release" {
  description = "The SPS release version"
  type        = string
}

variable "eks_cluster_name" {
  description = "value"
  type        = string
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "docker_images" {
  description = "Docker images for the Unity SPS containers"
  type        = map(string)
}

variable "elb_subnets" {
  description = "value"
  type        = string
}
