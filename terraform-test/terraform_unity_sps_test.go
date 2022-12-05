package test

import (
	"fmt"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// https://terratest.gruntwork.io/docs/getting-started/quick-start/
func TestTerraformUnity(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../terraform-unity",

		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"terraform.tfvars"},

		// Disable colors in Terraform commands so its easier to parse stdout/stderr
		NoColor: true,
	})

	// Clean up resources with "terraform destroy". Using "defer" runs the command at the end of the test, whether the test succeeds or fails.
	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply".
	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	loadBalancerHostnames := terraform.OutputMap(t, terraformOptions, "load_balancer_hostnames")

	ades_wpst_api_url := fmt.Sprintf("http://%s:5001/api/docs", loadBalancerHostnames["ades_wpst_api"])
	statusCode, _ := http_helper.HttpGet(t, ades_wpst_api_url, nil)
	assert.Equal(t, statusCode, 200)
}
