variable "project" {
  description = "The project or mission deploying Unity SPS"
  type        = string
  default     = "unity"
}

variable "venue" {
  description = "The venue into which is being deployed"
  type        = string
}

variable "service_area" {
  description = "The service area owner of the resources being deployed"
  type        = string
  default     = "sps"
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "ghcr_pat" {
  description = "Personal Access Token (PAT) for the Github Container Registry (GHCR)"
  type        = string
}

variable "uds_staging_bucket" {
  description = "The name of the U-DS staging bucket"
  type        = string
}

variable "uds_client_id" {
  description = "The ID of the U-DS client"
  type        = string
}

variable "uds_dapa_api" {
  description = "The U-DS API endpoint"
  type        = string
}
