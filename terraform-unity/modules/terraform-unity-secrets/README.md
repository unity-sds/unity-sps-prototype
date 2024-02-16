# terraform-unity-secrets

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.36.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.ghcr_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.uds_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.uds_dapa_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.uds_staging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ghcr_pat"></a> [ghcr\_pat](#input\_ghcr\_pat) | Personal Access Token (PAT) for the Github Container Registry (GHCR) | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project or mission deploying Unity SPS | `string` | `"unity"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region | `string` | `"us-west-2"` | no |
| <a name="input_release"></a> [release](#input\_release) | The SPS release version | `string` | n/a | yes |
| <a name="input_service_area"></a> [service\_area](#input\_service\_area) | The service area owner of the resources being deployed | `string` | `"sps"` | no |
| <a name="input_uds_client_id"></a> [uds\_client\_id](#input\_uds\_client\_id) | The ID of the U-DS client | `string` | n/a | yes |
| <a name="input_uds_dapa_api"></a> [uds\_dapa\_api](#input\_uds\_dapa\_api) | The U-DS API endpoint | `string` | n/a | yes |
| <a name="input_uds_staging_bucket"></a> [uds\_staging\_bucket](#input\_uds\_staging\_bucket) | The name of the U-DS staging bucket | `string` | n/a | yes |
| <a name="input_venue"></a> [venue](#input\_venue) | The venue into which is being deployed | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
