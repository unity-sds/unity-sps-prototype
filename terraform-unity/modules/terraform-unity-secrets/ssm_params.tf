resource "aws_ssm_parameter" "ghcr_pat" {
  name        = format("/%s-%s-%s-deployment-ghcr_pat", var.project, var.venue, var.service_area)
  description = "Personal Access Token (PAT) for U-SPS packages in the Github Container Registry (GHCR)"
  type        = "SecureString"
  value       = var.ghcr_pat
  overwrite   = true
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-Deployment-GHCRPAT"
    Component = "Deployment"
    Stack     = "Deployment"
  })
}

resource "aws_ssm_parameter" "uds_staging_bucket" {
  name        = format("/%s-%s-%s-deployment-uds_staging_bucket", var.project, var.venue, var.service_area)
  description = "The name of the U-DS staging bucket"
  type        = "SecureString"
  value       = var.uds_staging_bucket
  overwrite   = true
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-Deployment-UDSStagingBucket"
    Component = "Deployment"
    Stack     = "Deployment"
  })
}

resource "aws_ssm_parameter" "uds_client_id" {
  name        = format("/%s-%s-%s-deployment-uds_client_id", var.project, var.venue, var.service_area)
  description = "The ID of the U-DS client"
  type        = "SecureString"
  value       = var.uds_client_id
  overwrite   = true
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-Deployment-UDSClientID"
    Component = "Deployment"
    Stack     = "Deployment"
  })
}

resource "aws_ssm_parameter" "uds_dapa_api" {
  name        = format("/%s-%s-%s-deployment-uds_dapa_api", var.project, var.venue, var.service_area)
  description = "The U-DS API endpoint"
  type        = "SecureString"
  value       = var.uds_dapa_api
  overwrite   = true
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-Deployment-UDSDAPAAPI"
    Component = "Deployment"
    Stack     = "Deployment"
  })
}
