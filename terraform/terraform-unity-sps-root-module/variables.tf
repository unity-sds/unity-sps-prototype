variable "namespace" {
  description = "Namespace for the Unity SPS HySDS-related Kubernetes resources"
  type        = string
}

variable "kubeconfig_filepath" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
}

variable "base64_encoded_dockerconfig" {
  description = "Base64 encoded Docker config json file"
  type        = string
}
