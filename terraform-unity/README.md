<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.57.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_unity-sps-hysds-cluster"></a> [unity-sps-hysds-cluster](#module\_unity-sps-hysds-cluster) | ../terraform-modules/terraform-unity-sps-hysds-cluster | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.account_project](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.account_venue](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.default_group_node_group_launch_template_name](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.default_node_group_name](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.eks_private_subnets](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.ghcr_pat](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uads_development_efs_fsmt_id](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uds_client_id](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uds_dapa_api](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uds_staging_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_routes_to_api_gateway"></a> [add\_routes\_to\_api\_gateway](#input\_add\_routes\_to\_api\_gateway) | If true, adds routes to api gateway configured in account | `bool` | `false` | no |
| <a name="input_celeryconfig_filename"></a> [celeryconfig\_filename](#input\_celeryconfig\_filename) | value | `string` | `"celeryconfig_remote.py"` | no |
| <a name="input_container_registry_owner"></a> [container\_registry\_owner](#input\_container\_registry\_owner) | value | `string` | `"unity-sds/unity-sps-prototype"` | no |
| <a name="input_container_registry_server"></a> [container\_registry\_server](#input\_container\_registry\_server) | value | `string` | `"ghcr.io"` | no |
| <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username) | value | `string` | `"drewm-jpl"` | no |
| <a name="input_counter"></a> [counter](#input\_counter) | value | `string` | `""` | no |
| <a name="input_datasets_filename"></a> [datasets\_filename](#input\_datasets\_filename) | value | `string` | `"datasets.remote.template.json"` | no |
| <a name="input_default_group_node_group_launch_template_name"></a> [default\_group\_node\_group\_launch\_template\_name](#input\_default\_group\_node\_group\_launch\_template\_name) | value | `string` | `null` | no |
| <a name="input_default_group_node_group_name"></a> [default\_group\_node\_group\_name](#input\_default\_group\_node\_group\_name) | value | `string` | `null` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Unique name of this deployment in the account. | `string` | n/a | yes |
| <a name="input_docker_images"></a> [docker\_images](#input\_docker\_images) | Docker images for the Unity SPS containers | `map(string)` | <pre>{<br>  "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v1.0.0",<br>  "busybox": "busybox:1.36.0",<br>  "dind": "docker:23.0.3-dind",<br>  "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v1.0.0",<br>  "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v1.0.0",<br>  "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v1.0.0",<br>  "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v1.0.0",<br>  "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v1.0.0",<br>  "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v1.0.0",<br>  "logstash": "docker.elastic.co/logstash/logstash:7.10.2",<br>  "rabbitmq": "rabbitmq:3.11.13-management",<br>  "redis": "redis:7.0.10",<br>  "sps_api": "ghcr.io/unity-sds/unity-sps-prototype/sps-api:unity-v1.0.0",<br>  "sps_hysds_pge_base": "ghcr.io/unity-sds/unity-sps-prototype/sps-hysds-pge-base:unity-v1.0.0"<br>}</pre> | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The name of the EKS cluster. | `string` | n/a | yes |
| <a name="input_elb_subnets"></a> [elb\_subnets](#input\_elb\_subnets) | value | `string` | `null` | no |
| <a name="input_kubeconfig_filepath"></a> [kubeconfig\_filepath](#input\_kubeconfig\_filepath) | Path to the kubeconfig file for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Unity SPS HySDS-related Kubernetes resources | `string` | `"unity-sps"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project or mission deploying Unity SPS | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region | `string` | `"us-west-2"` | no |
| <a name="input_release"></a> [release](#input\_release) | The SPS release version | `string` | n/a | yes |
| <a name="input_service_area"></a> [service\_area](#input\_service\_area) | The service area owner of the resources being deployed | `string` | `"sps"` | no |
| <a name="input_service_port_map"></a> [service\_port\_map](#input\_service\_port\_map) | value | `map(number)` | <pre>{<br>  "ades_wpst_api_service": 5001,<br>  "grq2_es": 9201,<br>  "grq2_service": 8878,<br>  "hysds_ui_service": 3000,<br>  "mozart_es": 9200,<br>  "mozart_service": 8888,<br>  "rabbitmq_mgmt_service_cluster_rpc": 15672,<br>  "rabbitmq_service_cluster_rpc": 15672,<br>  "rabbitmq_service_epmd": 4369,<br>  "rabbitmq_service_listener": 5672,<br>  "redis_service": 6379,<br>  "sps_api_service": 5002<br>}</pre> | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | value | `string` | `"LoadBalancer"` | no |
| <a name="input_uads_development_efs_fsmt_id"></a> [uads\_development\_efs\_fsmt\_id](#input\_uads\_development\_efs\_fsmt\_id) | value | `string` | `null` | no |
| <a name="input_venue"></a> [venue](#input\_venue) | The MCP venue in which the cluster will be deployed (dev, test, prod) | `string` | `null` | no |
| <a name="input_verdi_node_group_capacity_type"></a> [verdi\_node\_group\_capacity\_type](#input\_verdi\_node\_group\_capacity\_type) | value | `string` | `"ON_DEMAND"` | no |
| <a name="input_verdi_node_group_instance_types"></a> [verdi\_node\_group\_instance\_types](#input\_verdi\_node\_group\_instance\_types) | value | `list(string)` | <pre>[<br>  "m3.medium"<br>]</pre> | no |
| <a name="input_verdi_node_group_scaling_config"></a> [verdi\_node\_group\_scaling\_config](#input\_verdi\_node\_group\_scaling\_config) | value | `map(number)` | <pre>{<br>  "desired_size": 3,<br>  "max_size": 10,<br>  "min_size": 0<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_hostnames"></a> [load\_balancer\_hostnames](#output\_load\_balancer\_hostnames) | Load Balancer Ingress Hostnames |
<!-- END_TF_DOCS -->