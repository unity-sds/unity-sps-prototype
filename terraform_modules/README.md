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

### Auto-generate a terraform.tfvars template file:

```shell
$ cd terraform-unity-sps-root-module
$ terraform-docs tfvars hcl .
container_registry_password = ""
container_registry_server   = ""
container_registry_username = ""
kubeconfig_filepath         = ""
namespace                   = ""
```

### Prior to pushing to the repo, please ensure that you done have the following and the checks have passed:

1. Run the pre-commit hooks. These hooks will perform static analysis, linting, security checks. The hooks will also reformat the code to conform to the style guide, and produce the auto-generated documentation of the Terraform module.

   ```shell
   # Run all hooks:
   $ pre-commit run --files terraform_modules/*

   # Run specific hook:
   $ pre-commit run <hook_id> --files terraform_modules/*
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

# Auto-generated Documentation of Terraform Modules

Each module contained in this directory contains its own auto-generated documentation.
