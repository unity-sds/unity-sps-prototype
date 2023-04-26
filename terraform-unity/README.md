# Unity SPS Cluster Provisioning with Terraform

## Development Workflow

### Dev Requirements:

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
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
$ terraform-docs tfvars hcl . --output-file "terraform.tfvars"
```

```json
<!-- BEGIN_TF_DOCS -->
celeryconfig_filename  = "celeryconfig_remote.py"
counter                = ""
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
  "mozart_service": 30001
}
service_type = "LoadBalancer"
venue        = ""
<!-- END_TF_DOCS -->%
```

## Deploy the Cluster

### Deploying in into Different MCP Venues

### Deploying into Different EKS Clusters

This method will use Terraform to deploy the Kubernetes cluster represented by the `~/.kube/config` file which is referenced in `terraform-unity/main.tf`. Terraform will deploy the resources in the Kubernetes namespace named in `terrafrom/variables.tf` (defaults to `unity-sps`). Additional variables (including secrets) can be set in `terraform.tfvars`, a template is shown below.

From within the Terraform root module directory (`terraform-unity/`), run the following commands to initialize, and apply the Terraform module:

```bash
$ cd terraform-unity/
$ terraform init
$ terraform apply
```

## Teardown the Cluster

From within the Terraform root module directory (terraform-unity/), run the following command to destroy the SPS cluster:

```
$ terraform destroy
```

## Prior to pushing new changes to the repo, please ensure that you done have the following and the checks have passed:

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

## Debugging a Terraform Deployment

It is often useful to modify the level of TF_LOG environment variable when debugging
a Terraform deployment. The levels include: `TRACE`, `DEBUG`, `INFO`, `WARN`, and `ERROR`.

An example of setting the `TF_LOG` environment variable to `INFO`:

```bash
$ export TF_LOG=INFO
```

Additionally, it is also often useful to pipe the output of a Terraform deployment into a log file.

An example of piping the `terraform apply` output into a file named apply_output.txt:

```bash
$ terraform apply -no-color 2>&1 | tee apply_output.txt
```

Occasionally, a Terraform deployment goes awry and Terraform loses track of existing resources. When this happens, `terraform destroy` is unable to clean up the resources and you'll likely end up with existing resource errors when attempting your next `terraform apply`. This requires some manual garbage collection of the lingering orphan resources. It also sometimes requires nuking the existing Terraform-related state tracking files/directory.

The following commands are useful for manually ensuring all orphan resources are destroyed:

```bash
$ helm uninstall mozart-es
$ helm uninstall grq-es
$ kubectl delete all --all -n unity-sps
$ kubectl delete cm --all -n unity-sps # deletes ConfigMap(s)
$ kubectl delete pvc --all -n unity-sps # deletes PersistentVolumeClaim(s)
$ kubectl delete pv --all -n unity-sps # deletes PersistentVolume(s)
$ kubectl delete namespaces unity-sps
$ rm -rf .terraform
$ rm terraform.tfstate
$ rm terraform.tf.backup
```

# Auto-generated Documentation of the Unity SPS Terraform Root Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
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
| [aws_ssm_parameter.ghcr_pat](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uds_client_id](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uds_dapa_api](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.uds_staging_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_celeryconfig_filename"></a> [celeryconfig\_filename](#input\_celeryconfig\_filename) | value | `string` | `"celeryconfig_remote.py"` | no |
| <a name="input_container_registry_owner"></a> [container\_registry\_owner](#input\_container\_registry\_owner) | value | `string` | `"unity-sds/unity-sps-prototype"` | no |
| <a name="input_container_registry_server"></a> [container\_registry\_server](#input\_container\_registry\_server) | value | `string` | `"ghcr.io"` | no |
| <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username) | value | `string` | `"drewm-jpl"` | no |
| <a name="input_counter"></a> [counter](#input\_counter) | value | `string` | `""` | no |
| <a name="input_datasets_filename"></a> [datasets\_filename](#input\_datasets\_filename) | value | `string` | `"datasets.remote.template.json"` | no |
| <a name="input_default_group_node_group_launch_template_name"></a> [default\_group\_node\_group\_launch\_template\_name](#input\_default\_group\_node\_group\_launch\_template\_name) | value | `string` | n/a | yes |
| <a name="input_eks_node_groups.default[0]"></a> [default\_group\_node\_group\_name](#input\_default\_group\_node\_group\_name) | value | `string` | n/a | yes |
| <a name="input_docker_images"></a> [docker\_images](#input\_docker\_images) | Docker images for the Unity SPS containers | `map(string)` | <pre>{<br>  "ades_wpst_api": "ghcr.io/unity-sds/unity-sps-prototype/ades-wpst-api:unity-v1.0.0",<br>  "busybox": "busybox:1.36.0",<br>  "dind": "docker:23.0.3-dind",<br>  "hysds_core": "ghcr.io/unity-sds/unity-sps-prototype/hysds-core:unity-v1.0.0",<br>  "hysds_factotum": "ghcr.io/unity-sds/unity-sps-prototype/hysds-factotum:unity-v1.0.0",<br>  "hysds_grq2": "ghcr.io/unity-sds/unity-sps-prototype/hysds-grq2:unity-v1.0.0",<br>  "hysds_mozart": "ghcr.io/unity-sds/unity-sps-prototype/hysds-mozart:unity-v1.0.0",<br>  "hysds_ui": "ghcr.io/unity-sds/unity-sps-prototype/hysds-ui-remote:unity-v1.0.0",<br>  "hysds_verdi": "ghcr.io/unity-sds/unity-sps-prototype/hysds-verdi:unity-v1.0.0",<br>  "logstash": "docker.elastic.co/logstash/logstash:7.10.2",<br>  "rabbitmq": "rabbitmq:3.11.13-management",<br>  "redis": "redis:7.0.10",<br>  "sps_api": "ghcr.io/unity-sds/unity-sps-prototype/sps-api:unity-v1.0.0",<br>  "sps_hysds_pge_base": "ghcr.io/unity-sds/unity-sps-prototype/sps-hysds-pge-base:unity-v1.0.0"<br>}</pre> | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The name of the EKS cluster. | `string` | n/a | yes |
| <a name="input_subnets.private"></a> [elb\_subnet](#input\_elb\_subnet) | value | `string` | n/a | yes |
| <a name="input_kubeconfig_filepath"></a> [kubeconfig\_filepath](#input\_kubeconfig\_filepath) | Path to the kubeconfig file for the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Unity SPS HySDS-related Kubernetes resources | `string` | `"unity-sps"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project or mission deploying Unity SPS | `string` | `"unity"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region | `string` | `"us-west-2"` | no |
| <a name="input_release"></a> [release](#input\_release) | The SPS release version | `string` | n/a | yes |
| <a name="input_service_area"></a> [service\_area](#input\_service\_area) | The service area owner of the resources being deployed | `string` | `"sps"` | no |
| <a name="input_service_port_map"></a> [service\_port\_map](#input\_service\_port\_map) | value | `map(number)` | <pre>{<br>  "ades_wpst_api_service": 5001,<br>  "grq2_es": 9201,<br>  "grq2_service": 8878,<br>  "hysds_ui_service": 3000,<br>  "mozart_es": 9200,<br>  "mozart_service": 8888,<br>  "rabbitmq_mgmt_service_cluster_rpc": 15672,<br>  "rabbitmq_service_cluster_rpc": 15672,<br>  "rabbitmq_service_epmd": 4369,<br>  "rabbitmq_service_listener": 5672,<br>  "redis_service": 6379,<br>  "sps_api_service": 5002<br>}</pre> | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | value | `string` | `"LoadBalancer"` | no |
| <a name="input_uads_development_efs_fsmt_id"></a> [uads\_development\_efs\_fsmt\_id](#input\_uads\_development\_efs\_fsmt\_id) | value | `string` | `null` | no |
| <a name="input_venue"></a> [venue](#input\_venue) | The MCP venue in which the cluster will be deployed (dev, test, prod) | `string` | n/a | yes |
| <a name="input_verdi_node_group_capacity_type"></a> [verdi\_node\_group\_capacity\_type](#input\_verdi\_node\_group\_capacity\_type) | value | `string` | `"ON_DEMAND"` | no |
| <a name="input_verdi_node_group_instance_types"></a> [verdi\_node\_group\_instance\_types](#input\_verdi\_node\_group\_instance\_types) | value | `list(string)` | <pre>[<br>  "m3.medium"<br>]</pre> | no |
| <a name="input_verdi_node_group_scaling_config"></a> [verdi\_node\_group\_scaling\_config](#input\_verdi\_node\_group\_scaling\_config) | value | `map(number)` | <pre>{<br>  "desired_size": 3,<br>  "max_size": 10,<br>  "min_size": 0<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_hostnames"></a> [load\_balancer\_hostnames](#output\_load\_balancer\_hostnames) | Load Balancer Ingress Hostnames |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
