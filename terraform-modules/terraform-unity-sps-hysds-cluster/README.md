# terraform-unity-sps-hysds-cluster

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.57.1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.19.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.19.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_node_group.sps_api](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/eks_node_group) | resource |
| [aws_eks_node_group.verdi](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/eks_node_group) | resource |
| [aws_iam_policy.eks_sps_api_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks_sps_api_node_role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_verdi_node_role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_sps_api_node_group_scaling_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_sps_api_node_role_customer_policies](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_sps_api_node_role_managed_policies](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_verdi_node_role_customer_policies](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_verdi_node_role_managed_policies](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group_rule.efs_egress](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.efs_ingress](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.update_ades_wpst_url_stage_variable_of_api_gateway](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/ssm_parameter) | resource |
| [helm_release.grq2-es](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [helm_release.mozart-es](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [kubernetes_config_map.aws-credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.celeryconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.cwl-workflow-utils](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.cwl-workflows](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.datasets](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.grq2-settings](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.logstash-configs](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.mozart-settings](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.netrc](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-job-worker](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-orchestrator](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-user-rules](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_config_map.supervisord-verdi](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/config_map) | resource |
| [kubernetes_daemonset.verdi](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/daemonset) | resource |
| [kubernetes_deployment.ades-wpst-api](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.factotum-job-worker](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.grq2](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.hysds-ui](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.logstash](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.mozart](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.orchestrator](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.redis](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.sps-api](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_deployment.user-rules](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/deployment) | resource |
| [kubernetes_namespace.unity-sps](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/namespace) | resource |
| [kubernetes_persistent_volume.ades-wpst-sqlite-pv](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume.grq-es-pv](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume.mozart-es-pv](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume.uads-development-efs](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.uads-development-efs](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_role.verdi-reader](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/role) | resource |
| [kubernetes_role_binding.verdi-reader-binding](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/role_binding) | resource |
| [kubernetes_secret.sps-api](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/secret) | resource |
| [kubernetes_service.ades-wpst-api-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.grq2-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.hysds-ui-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.mozart-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.rabbitmq-mgmt-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.rabbitmq-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.redis_service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service.sps-api-service](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service) | resource |
| [kubernetes_service_account.sps-api](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/service_account) | resource |
| [kubernetes_stateful_set.rabbitmq_statefulset](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/stateful_set) | resource |
| [kubernetes_storage_class.efs_storage_class](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/storage_class) | resource |
| [random_id.counter](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_uuid.boundary_uuid](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/caller_identity) | data source |
| [aws_efs_mount_target.uads-development-efs-fsmt](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/efs_mount_target) | data source |
| [aws_eks_cluster.sps-cluster](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/eks_cluster) | data source |
| [aws_launch_template.default_group_node_group](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/launch_template) | data source |
| [aws_subnets.eks_subnets](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/subnets) | data source |
| [aws_vpc.eks_vpc](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/vpc) | data source |
| [kubernetes_service.grq-es](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/data-sources/service) | data source |
| [kubernetes_service.mozart-es](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_celeryconfig_filename"></a> [celeryconfig\_filename](#input\_celeryconfig\_filename) | value | `string` | `"celeryconfig_remote.py"` | no |
| <a name="input_container_registry_owner"></a> [container\_registry\_owner](#input\_container\_registry\_owner) | value | `string` | n/a | yes |
| <a name="input_container_registry_pat"></a> [container\_registry\_pat](#input\_container\_registry\_pat) | value | `string` | n/a | yes |
| <a name="input_container_registry_server"></a> [container\_registry\_server](#input\_container\_registry\_server) | value | `string` | n/a | yes |
| <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username) | value | `string` | n/a | yes |
| <a name="input_counter"></a> [counter](#input\_counter) | value | `string` | `""` | no |
| <a name="input_datasets_filename"></a> [datasets\_filename](#input\_datasets\_filename) | value | `string` | `"datasets.remote.template.json"` | no |
| <a name="input_default_group_node_group_launch_template_name"></a> [default\_group\_node\_group\_launch\_template\_name](#input\_default\_group\_node\_group\_launch\_template\_name) | value | `string` | n/a | yes |
| <a name="input_default_group_node_group_name"></a> [default\_group\_node\_group\_name](#input\_default\_group\_node\_group\_name) | value | `string` | n/a | yes |
| <a name="input_docker_images"></a> [docker\_images](#input\_docker\_images) | Docker images for the Unity SPS containers | `map(string)` | <pre>{<br>  "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1",<br>  "busybox": "k8s.gcr.io/busybox",<br>  "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1",<br>  "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1",<br>  "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1",<br>  "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1",<br>  "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1",<br>  "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1",<br>  "logstash": "docker.elastic.co/logstash/logstash:7.10.2",<br>  "rabbitmq": "rabbitmq:3-management",<br>  "redis": "redis:latest",<br>  "sps_api": "ghcr.io/unity-sds/unity-sps-prototype/sps-api:unity-v0.0.1",<br>  "sps_hysds_pge_base": "ghcr.io/unity-sds/unity-sps-prototype/sps-hysds-pge-base:unity-v0.0.1"<br>}</pre> | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | value | `string` | n/a | yes |
| <a name="input_elb_subnet"></a> [elb\_subnet](#input\_elb\_subnet) | value | `string` | n/a | yes |
| <a name="input_kubeconfig_filepath"></a> [kubeconfig\_filepath](#input\_kubeconfig\_filepath) | Path to the kubeconfig file for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Unity SPS HySDS-related Kubernetes resources | `string` | `"unity-sps"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project or mission deploying Unity SPS | `string` | `"unity"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region | `string` | `"us-west-2"` | no |
| <a name="input_release"></a> [release](#input\_release) | The SPS release version | `string` | n/a | yes |
| <a name="input_service_area"></a> [service\_area](#input\_service\_area) | The service area owner of the resources being deployed | `string` | `"sps"` | no |
| <a name="input_service_port_map"></a> [service\_port\_map](#input\_service\_port\_map) | value | `map(number)` | <pre>{<br>  "ades_wpst_api_service": 5001,<br>  "grq2_es": 9201,<br>  "grq2_service": 8878,<br>  "hysds_ui_service": 3000,<br>  "mozart_es": 9200,<br>  "mozart_service": 8888,<br>  "rabbitmq_mgmt_service_cluster_rpc": 15672,<br>  "rabbitmq_service_cluster_rpc": 15672,<br>  "rabbitmq_service_epmd": 4369,<br>  "rabbitmq_service_listener": 5672,<br>  "redis_service": 6379,<br>  "sps_api_service": 5002<br>}</pre> | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | value | `string` | `"LoadBalancer"` | no |
| <a name="input_uads_development_efs_fsmt_id"></a> [uads\_development\_efs\_fsmt\_id](#input\_uads\_development\_efs\_fsmt\_id) | value | `string` | `null` | no |
| <a name="input_uds_client_id"></a> [uds\_client\_id](#input\_uds\_client\_id) | value | `string` | n/a | yes |
| <a name="input_uds_dapa_api"></a> [uds\_dapa\_api](#input\_uds\_dapa\_api) | value | `string` | n/a | yes |
| <a name="input_uds_staging_bucket"></a> [uds\_staging\_bucket](#input\_uds\_staging\_bucket) | value | `string` | n/a | yes |
| <a name="input_venue"></a> [venue](#input\_venue) | The MCP venue in which the cluster will be deployed (dev, test, prod) | `string` | n/a | yes |
| <a name="input_verdi_node_group_capacity_type"></a> [verdi\_node\_group\_capacity\_type](#input\_verdi\_node\_group\_capacity\_type) | value | `string` | `"ON_DEMAND"` | no |
| <a name="input_verdi_node_group_instance_types"></a> [verdi\_node\_group\_instance\_types](#input\_verdi\_node\_group\_instance\_types) | value | `list(string)` | <pre>[<br>  "m3.medium"<br>]</pre> | no |
| <a name="input_verdi_node_group_scaling_config"></a> [verdi\_node\_group\_scaling\_config](#input\_verdi\_node\_group\_scaling\_config) | value | `map(number)` | <pre>{<br>  "desired_size": 3,<br>  "max_size": 10,<br>  "min_size": 0<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_hostnames"></a> [load\_balancer\_hostnames](#output\_load\_balancer\_hostnames) | Load Balancer Ingress Hostnames |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
