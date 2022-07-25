# terraform-unity

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_unity-sps-hysds-cluster"></a> [unity-sps-hysds-cluster](#module\_unity-sps-hysds-cluster) | ../terraform-modules/terraform-unity-sps-hysds-cluster | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_celeryconfig_filename"></a> [celeryconfig\_filename](#input\_celeryconfig\_filename) | value | `string` | `"celeryconfig_remote.py"` | no |
| <a name="input_datasets_filename"></a> [datasets\_filename](#input\_datasets\_filename) | value | `string` | `"datasets.remote.template.json"` | no |
| <a name="input_deployment_environment"></a> [deployment\_environment](#input\_deployment\_environment) | value | `string` | `"mcp"` | no |
| <a name="input_docker_images"></a> [docker\_images](#input\_docker\_images) | Docker images for the Unity SPS containers | `map(string)` | <pre>{<br>  "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1",<br>  "busybox": "k8s.gcr.io/busybox",<br>  "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1",<br>  "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1",<br>  "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1",<br>  "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1",<br>  "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1",<br>  "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1",<br>  "logstash": "docker.elastic.co/logstash/logstash:7.10.2",<br>  "mc": "minio/mc:RELEASE.2022-03-13T22-34-00Z",<br>  "minio": "minio/minio:RELEASE.2022-03-17T06-34-49Z",<br>  "rabbitmq": "rabbitmq:3-management",<br>  "redis": "redis:latest"<br>}</pre> | no |
| <a name="input_kubeconfig_filepath"></a> [kubeconfig\_filepath](#input\_kubeconfig\_filepath) | Path to the kubeconfig file for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_mozart_es"></a> [mozart\_es](#input\_mozart\_es) | value | <pre>object({<br>    volume_claim_template = object({<br>      storage_class_name = string<br>    })<br>  })</pre> | <pre>{<br>  "volume_claim_template": {<br>    "storage_class_name": "gp2-sps"<br>  }<br>}</pre> | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Unity SPS HySDS-related Kubernetes resources | `string` | n/a | yes |
| <a name="input_node_port_map"></a> [node\_port\_map](#input\_node\_port\_map) | value | `map(number)` | <pre>{<br>  "ades_wpst_api_service": 30011,<br>  "grq2_es": 30012,<br>  "grq2_service": 30002,<br>  "hysds_ui_service": 30009,<br>  "minio_service_api": 30007,<br>  "minio_service_interface": 30008,<br>  "mozart_es": 30013,<br>  "mozart_service": 30001,<br>  "rabbitmq_mgmt_service_cluster_rpc": 30003,<br>  "rabbitmq_service_cluster_rpc": 30006,<br>  "rabbitmq_service_epmd": 30004,<br>  "rabbitmq_service_listener": 30005,<br>  "redis_service": 30010<br>}</pre> | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | value | `string` | `"LoadBalancer"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_hostnames"></a> [load\_balancer\_hostnames](#output\_load\_balancer\_hostnames) | Load Balancer Ingress Hostnames |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
