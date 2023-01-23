resource "aws_ssm_parameter" "ghcr_pat" {
  name        = format("/%s-%s-%s-deployment-ghcr_pat", var.project, var.venue, var.service_area)
  description = "Personal Access Token (PAT) for U-SPS packages in the Github Container Registry (GHCR)"
  type        = "SecureString"
  value       = var.ghcr_pat
  overwrite   = true
  tags = {
    project      = var.project
    venue        = var.venue
    service_area = var.service_area
    capability   = "deployment"
  }
}

resource "aws_ssm_parameter" "uds_staging_bucket" {
  name        = format("/%s-%s-%s-deployment-uds_staging_bucket", var.project, var.venue, var.service_area)
  description = "The name of the U-DS staging bucket"
  type        = "SecureString"
  value       = var.uds_staging_bucket
  overwrite   = true
  tags = {
    project      = var.project
    venue        = var.venue
    service_area = var.service_area
    capability   = "deployment"
  }
}

resource "aws_ssm_parameter" "uds_client_id" {
  name        = format("/%s-%s-%s-deployment-uds_client_id", var.project, var.venue, var.service_area)
  description = "The ID of the U-DS client"
  type        = "SecureString"
  value       = var.uds_client_id
  overwrite   = true
  tags = {
    project      = var.project
    venue        = var.venue
    service_area = var.service_area
    capability   = "deployment"
  }
}

resource "aws_ssm_parameter" "uds_dapa_api" {
  name        = format("/%s-%s-%s-deployment-uds_dapa_api", var.project, var.venue, var.service_area)
  description = "The U-DS API endpoint"
  type        = "SecureString"
  value       = var.uds_dapa_api
  overwrite   = true
  tags = {
    project      = var.project
    venue        = var.venue
    service_area = var.service_area
    capability   = "deployment"
  }
}
