# terraform-unity-sps-hysds-cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.23.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.12.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.23.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.s3_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_object.source_files](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/s3_object) | resource |
| [aws_ssm_parameter.update_ades_wpst_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.update_grq_es_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.update_grq_rest_api_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.update_hysds_ui_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.update_mozart_es_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.update_mozart_rest_api_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.23.0/docs/resources/ssm_parameter) | resource |
| [helm_release.grq2-es](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [helm_release.mozart-es](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [kubernetes_config_map.aws-credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.celeryconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.cwl-workflow-utils](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.cwl-workflows](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.datasets](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.grq2-settings](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.logstash-configs](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.mozart-settings](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.netrc](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.sounder-sips-static-data](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-job-worker](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-orchestrator](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-user-rules](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-verdi](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/config_map) | resource |
| [kubernetes_deployment.ades-wpst-api](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.factotum-job-worker](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.grq2](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.hysds-ui](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.logstash](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.minio](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.mozart](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.orchestrator](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.redis](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.user-rules](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_deployment.verdi](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment) | resource |
| [kubernetes_job.mc](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/job) | resource |
| [kubernetes_namespace.unity-sps](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/namespace) | resource |
| [kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.minio-pv-claim](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_service.ades-wpst-api-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.grq2-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.hysds-ui-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.minio-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.mozart-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.rabbitmq-mgmt-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.rabbitmq-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_service.redis_service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service) | resource |
| [kubernetes_stateful_set.rabbitmq_statefulset](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/stateful_set) | resource |
| [kubernetes_service.grq-es](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/data-sources/service) | data source |
| [kubernetes_service.mozart-es](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_celeryconfig_filename"></a> [celeryconfig\_filename](#input\_celeryconfig\_filename) | value | `string` | `"celeryconfig_remote.py"` | no |
| <a name="input_counter"></a> [counter](#input\_counter) | value | `number` | n/a | yes |
| <a name="input_datasets_filename"></a> [datasets\_filename](#input\_datasets\_filename) | value | `string` | `"datasets.remote.template.json"` | no |
| <a name="input_deployment_environment"></a> [deployment\_environment](#input\_deployment\_environment) | value | `string` | `"mcp"` | no |
| <a name="input_docker_images"></a> [docker\_images](#input\_docker\_images) | Docker images for the Unity SPS containers | `map(string)` | <pre>{<br>  "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1",<br>  "busybox": "k8s.gcr.io/busybox",<br>  "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1",<br>  "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1",<br>  "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1",<br>  "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1",<br>  "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1",<br>  "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1",<br>  "logstash": "docker.elastic.co/logstash/logstash:7.10.2",<br>  "mc": "minio/mc:RELEASE.2022-03-13T22-34-00Z",<br>  "minio": "minio/minio:RELEASE.2022-03-17T06-34-49Z",<br>  "rabbitmq": "rabbitmq:3-management",<br>  "redis": "redis:latest"<br>}</pre> | no |
| <a name="input_grq2_es"></a> [grq2\_es](#input\_grq2\_es) | value | <pre>object({<br>    volume_claim_template = object({<br>      storage_class_name = string<br>    })<br>  })</pre> | <pre>{<br>  "volume_claim_template": {<br>    "storage_class_name": "gp2-sps"<br>  }<br>}</pre> | no |
| <a name="input_kubeconfig_filepath"></a> [kubeconfig\_filepath](#input\_kubeconfig\_filepath) | Path to the kubeconfig file for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_mozart_es"></a> [mozart\_es](#input\_mozart\_es) | value | <pre>object({<br>    volume_claim_template = object({<br>      storage_class_name = string<br>    })<br>  })</pre> | <pre>{<br>  "volume_claim_template": {<br>    "storage_class_name": "gp2-sps"<br>  }<br>}</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Unity SPS HySDS-related Kubernetes resources | `string` | `"unity-sps"` | no |
| <a name="input_node_port_map"></a> [node\_port\_map](#input\_node\_port\_map) | value | `map(number)` | <pre>{<br>  "ades_wpst_api_service": 30011,<br>  "grq2_es": 30012,<br>  "grq2_service": 30002,<br>  "hysds_ui_service": 30009,<br>  "minio_service_api": 30007,<br>  "minio_service_interface": 30008,<br>  "mozart_es": 30013,<br>  "mozart_service": 30001<br>}</pre> | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | value | `string` | `"LoadBalancer"` | no |
| <a name="input_venue"></a> [venue](#input\_venue) | The MCP venue in which the cluster will be deployed (dev, test, prod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_hostnames"></a> [load\_balancer\_hostnames](#output\_load\_balancer\_hostnames) | Load Balancer Ingress Hostnames |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
