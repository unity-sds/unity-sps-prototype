data "aws_ssm_parameter" "ghcr_pat" {
  name = format("/%s-%s-%s-deployment-ghcr_pat", var.project, var.venue, var.service_area)
}
data "aws_ssm_parameter" "uds_staging_bucket" {
  name = format("/%s-%s-%s-deployment-uds_staging_bucket", var.project, var.venue, var.service_area)
}
data "aws_ssm_parameter" "uds_client_id" {
  name = format("/%s-%s-%s-deployment-uds_client_id", var.project, var.venue, var.service_area)
}
data "aws_ssm_parameter" "uds_dapa_api" {
  name = format("/%s-%s-%s-deployment-uds_dapa_api", var.project, var.venue, var.service_area)
}
