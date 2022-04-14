# Unity-SPS Cluster Provisioning with Terraform

## Development Workflow

### Dev Requirements:

- [tfenv](https://github.com/tfutils/tfenv) - Terraform version manager.
- [Pre-commit](https://pre-commit.com/) - Framework for managing and maintaining multi-language pre-commit hooks.
- [act](https://github.com/nektos/act) - Run Github Actions locally.
- [tflint](https://github.com/terraform-linters/tflint) - Terraform Linter.
- [terrascan](https://github.com/accurics/terrascan) - Static code analyzer for Infrastructure as Code.
- [tfsec](https://github.com/aquasecurity/tfsec) - Security scanner for Terraform code.
- [terraform-docs](https://github.com/terraform-docs/terraform-docs) - Generate documentation from Terraform modules.

### Prior to pushing to the repo, please ensure that you done have the following and the checks have passed:

1. Run the pre-commit hooks. These hooks will perform static analysis, linting, security checks. The hooks will also reformat the code to conform to the style guide, and produce the auto-generated documentation of the Terraform module.

   ```shell
   # Run all hooks:
   $ pre-commit run --files terraform/*

   # Run specific hook:
   $ pre-commit run <hook_id> --files terraform/*
   ```

2. Run the Github Actions locally. These actions include similar checks to the pre-commit hooks, however, the actions not have the ability to perform reformatting or auto-generation of documentation. This step is meant to mimic the Github Actions which run on the remote CI/CD pipeline.

   ```shell
   # Run all actions:
   $ act

   # Run specific action:
   $ act -j "<job_name>"
   ```

# Auto-generated Documentation of the Terraform Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

No requirements.

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_helm"></a> [helm](#provider_helm)                   | 2.4.1   |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes) | 2.8.0   |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                       | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [helm_release.grq2-es](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                                                               | resource |
| [helm_release.mozart-es](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)                                                             | resource |
| [kubernetes_config_map.aws-credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                     | resource |
| [kubernetes_config_map.celeryconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                        | resource |
| [kubernetes_config_map.datasets](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                            | resource |
| [kubernetes_config_map.grq2-settings](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                       | resource |
| [kubernetes_config_map.logstash-configs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                    | resource |
| [kubernetes_config_map.mozart-settings](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                     | resource |
| [kubernetes_config_map.netrc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                               | resource |
| [kubernetes_config_map.supervisord-job-worker](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                              | resource |
| [kubernetes_config_map.supervisord-orchestrator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                            | resource |
| [kubernetes_config_map.supervisord-user-rules](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                              | resource |
| [kubernetes_config_map.supervisord-verdi](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map)                                   | resource |
| [kubernetes_deployment.ades-wpst-api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                       | resource |
| [kubernetes_deployment.factotum-job-worker](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                 | resource |
| [kubernetes_deployment.grq2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                                | resource |
| [kubernetes_deployment.hysds-ui](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                            | resource |
| [kubernetes_deployment.logstash](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                            | resource |
| [kubernetes_deployment.minio](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                               | resource |
| [kubernetes_deployment.mozart](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                              | resource |
| [kubernetes_deployment.orchestrator](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                        | resource |
| [kubernetes_deployment.redis](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                               | resource |
| [kubernetes_deployment.user-rules](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                          | resource |
| [kubernetes_deployment.verdi](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)                                               | resource |
| [kubernetes_job.mc](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job)                                                                | resource |
| [kubernetes_namespace.unity-sps](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)                                             | resource |
| [kubernetes_persistent_volume_claim.ades-wpst-sqlite-pv-claim](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |
| [kubernetes_persistent_volume_claim.minio-pv-claim](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim)            | resource |
| [kubernetes_service.ades-wpst-api_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                     | resource |
| [kubernetes_service.grq2_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                              | resource |
| [kubernetes_service.hysds-ui_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                          | resource |
| [kubernetes_service.minio_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                             | resource |
| [kubernetes_service.mozart_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                            | resource |
| [kubernetes_service.rabbitmq_mgmt_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                     | resource |
| [kubernetes_service.rabbitmq_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                          | resource |
| [kubernetes_service.redis_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service)                                             | resource |
| [kubernetes_stateful_set.rabbitmq_statefulset](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set)                            | resource |

## Inputs

| Name                                                         | Description | Type     | Default       | Required |
| ------------------------------------------------------------ | ----------- | -------- | ------------- | :------: |
| <a name="input_namespace"></a> [namespace](#input_namespace) | unity-sps   | `string` | `"unity-sps"` |    no    |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
