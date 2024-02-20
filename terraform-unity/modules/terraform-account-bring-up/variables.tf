variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "service_area" {
  description = "The service area owner of the resources being deployed"
  type        = string
  default     = "sps"
}
