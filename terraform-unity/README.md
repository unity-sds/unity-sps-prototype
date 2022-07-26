# Unity SPS Cluster Provisioning with Terraform

## Development Workflow

### Dev Requirements:

- [tfenv](https://github.com/tfutils/tfenv) - Terraform version manager.
- [Pre-commit](https://pre-commit.com/) - Framework for managing and maintaining multi-language pre-commit hooks.
- [act](https://github.com/nektos/act) - Run Github Actions locally.
- [tflint](https://github.com/terraform-linters/tflint) - Terraform Linter.
- [terrascan](https://github.com/accurics/terrascan) - Static code analyzer for Infrastructure as Code.
- [tfsec](https://github.com/aquasecurity/tfsec) - Security scanner for Terraform code.
- [terraform-docs](https://github.com/terraform-docs/terraform-docs) - Generate documentation from Terraform modules.
- [Terratest](https://terratest.gruntwork.io) - Go library that provides patterns and helper functions for testing infrastructure, with 1st-class support for Terraform.

### Auto-generate a terraform.tfvars template file:

```shell
$ cd terraform-unity
$ terraform-docs tfvars hcl .
```

```json
celeryconfig_filename  = "celeryconfig_remote.py"
datasets_filename      = "datasets.remote.template.json"
deployment_environment = "mcp"
docker_images = {
  "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1",
  "busybox": "k8s.gcr.io/busybox",
  "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1",
  "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1",
  "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1",
  "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1",
  "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1",
  "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1",
  "logstash": "docker.elastic.co/logstash/logstash:7.10.2",
  "mc": "minio/mc:RELEASE.2022-03-13T22-34-00Z",
  "minio": "minio/minio:RELEASE.2022-03-17T06-34-49Z",
  "rabbitmq": "rabbitmq:3-management",
  "redis": "redis:latest"
}
kubeconfig_filepath = ""
mozart_es = {
  "volume_claim_template": {
    "storage_class_name": "gp2-sps"
  }
}
namespace = ""
node_port_map = {
  "ades_wpst_api_service": 30011,
  "grq2_es": 30012,
  "grq2_service": 30002,
  "hysds_ui_service": 30009,
  "minio_service_api": 30007,
  "minio_service_interface": 30008,
  "mozart_es": 30013,
  "mozart_service": 30001,
  "rabbitmq_mgmt_service_cluster_rpc": 30003,
  "rabbitmq_service_cluster_rpc": 30006,
  "rabbitmq_service_epmd": 30004,
  "rabbitmq_service_listener": 30005,
  "redis_service": 30010
}
service_type = "LoadBalancer"
```

### Prior to pushing to the repo, please ensure that you done have the following and the checks have passed:

1. Run the pre-commit hooks. These hooks will perform static analysis, linting, security checks. The hooks will also reformat the code to conform to the style guide, and produce the auto-generated documentation of the Terraform module.

   ```shell
   # Run all hooks:
   $ pre-commit run --files terraform-modules/*
   $ pre-commit run --files terraform-unity/*

   # Run specific hook:
   $ pre-commit run <hook_id> --files terraform-modules/terraform-unity-sps-hysds-cluster/*.tf
   $ pre-commit run <hook_id> --files terraform-unity/*.tf
   ```

2. Run the Github Actions locally. These actions include similar checks to the pre-commit hooks, however, the actions not have the ability to perform reformatting or auto-generation of documentation. This step is meant to mimic the Github Actions which run on the remote CI/CD pipeline.

   ```shell
   # Run all actions:
   $ act

   # Run specific action:
   $ act -j "<job_name>"
   $ act -j terraform_validate
   $ act -j terraform_fmt
   $ act -j terraform_tflint
   $ act -j terraform_tfsec
   $ act -j checkov

   # You may need to authenticate with Docker hub in order to successfully pull some of the associated images.
   $ act -j terraform_validate -s DOCKER_USERNAME=<insert-username> -s DOCKER_PASSWORD=<insert-password>
   ```

3. Run the Terratest smoke test. At the moment, this represents a **_very_** basic smoke test for our deployment which simply checks the endpoints of the various services.

   ```shell
   $ cd terraform-test
   $ go test -v -run TestTerraformUnity -timeout 30m | tee terratest_output.txt
   ```

# Auto-generated Documentation of the Unity SPS Terraform Root Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.1.9 |

## Providers

No providers.

## Modules

| Name                                                                                                     | Source                                                 | Version |
| -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ------- |
| <a name="module_unity-sps-hysds-cluster"></a> [unity-sps-hysds-cluster](#module_unity-sps-hysds-cluster) | ../terraform-modules/terraform-unity-sps-hysds-cluster | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                                | Description                                                    | Type                                                                                                   | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Required |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_celeryconfig_filename"></a> [celeryconfig_filename](#input_celeryconfig_filename)    | value                                                          | `string`                                                                                               | `"celeryconfig_remote.py"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |    no    |
| <a name="input_datasets_filename"></a> [datasets_filename](#input_datasets_filename)                | value                                                          | `string`                                                                                               | `"datasets.remote.template.json"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |    no    |
| <a name="input_deployment_environment"></a> [deployment_environment](#input_deployment_environment) | value                                                          | `string`                                                                                               | `"mcp"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |    no    |
| <a name="input_docker_images"></a> [docker_images](#input_docker_images)                            | Docker images for the Unity SPS containers                     | `map(string)`                                                                                          | <pre>{<br> "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v0.0.1",<br> "busybox": "k8s.gcr.io/busybox",<br> "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v0.0.1",<br> "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v0.0.1",<br> "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v0.0.1",<br> "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v0.0.1",<br> "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v0.0.1",<br> "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v0.0.1",<br> "logstash": "docker.elastic.co/logstash/logstash:7.10.2",<br> "mc": "minio/mc:RELEASE.2022-03-13T22-34-00Z",<br> "minio": "minio/minio:RELEASE.2022-03-17T06-34-49Z",<br> "rabbitmq": "rabbitmq:3-management",<br> "redis": "redis:latest"<br>}</pre> |    no    |
| <a name="input_kubeconfig_filepath"></a> [kubeconfig_filepath](#input_kubeconfig_filepath)          | Path to the kubeconfig file for the Kubernetes cluster         | `string`                                                                                               | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |   yes    |
| <a name="input_mozart_es"></a> [mozart_es](#input_mozart_es)                                        | value                                                          | <pre>object({<br> volume_claim_template = object({<br> storage_class_name = string<br> })<br> })</pre> | <pre>{<br> "volume_claim_template": {<br> "storage_class_name": "gp2-sps"<br> }<br>}</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |    no    |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                        | Namespace for the Unity SPS HySDS-related Kubernetes resources | `string`                                                                                               | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |   yes    |
| <a name="input_node_port_map"></a> [node_port_map](#input_node_port_map)                            | value                                                          | `map(number)`                                                                                          | <pre>{<br> "ades_wpst_api_service": 30011,<br> "grq2_es": 30012,<br> "grq2_service": 30002,<br> "hysds_ui_service": 30009,<br> "minio_service_api": 30007,<br> "minio_service_interface": 30008,<br> "mozart_es": 30013,<br> "mozart_service": 30001,<br> "rabbitmq_mgmt_service_cluster_rpc": 30003,<br> "rabbitmq_service_cluster_rpc": 30006,<br> "rabbitmq_service_epmd": 30004,<br> "rabbitmq_service_listener": 30005,<br> "redis_service": 30010<br>}</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                |    no    |
| <a name="input_service_type"></a> [service_type](#input_service_type)                               | value                                                          | `string`                                                                                               | `"LoadBalancer"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |    no    |

## Outputs

| Name                                                                                                     | Description                     |
| -------------------------------------------------------------------------------------------------------- | ------------------------------- |
| <a name="output_load_balancer_hostnames"></a> [load_balancer_hostnames](#output_load_balancer_hostnames) | Load Balancer Ingress Hostnames |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
