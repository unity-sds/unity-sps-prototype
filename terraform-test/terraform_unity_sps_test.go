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

	// Make an HTTP request to the instance and make sure we get back a 200 OK
	// hysds_ui_url := fmt.Sprintf("http://%s:3000", loadBalancerHostnames["hysds_ui"])
	// statusCode, _ := http_helper.HttpGet(t, hysds_ui_url, nil)
	// assert.Equal(t, statusCode, 200)

	// mozart_rest_api_url := fmt.Sprintf("http://%s:8888/api/v0.1/", loadBalancerHostnames["mozart_rest_api"])
	// statusCode, _ = http_helper.HttpGet(t, mozart_rest_api_url, nil)
	// assert.Equal(t, statusCode, 200)

	// mozart_es_url := fmt.Sprintf("http://%s:9200", loadBalancerHostnames["mozart_es"])
	// statusCode, _ = http_helper.HttpGet(t, mozart_es_url, nil)
	// assert.Equal(t, statusCode, 200)

	// grq_rest_api_url := fmt.Sprintf("http://%s:8878/api/v0.1/", loadBalancerHostnames["grq_rest_api"])
	// statusCode, _ = http_helper.HttpGet(t, grq_rest_api_url, nil)
	// assert.Equal(t, statusCode, 200)

	// grq_es_url := fmt.Sprintf("http://%s:9201", loadBalancerHostnames["grq_es"])
	// statusCode, _ = http_helper.HttpGet(t, grq_es_url, nil)
	// assert.Equal(t, statusCode, 200)

	ades_wpst_api_url := fmt.Sprintf("http://%s:5001/api/docs", loadBalancerHostnames["ades_wpst_api"])
	statusCode, _ := http_helper.HttpGet(t, ades_wpst_api_url, nil)
	assert.Equal(t, statusCode, 200)

	// minio_url := fmt.Sprintf("http://%s:9001", loadBalancerHostnames["minio"])
	// statusCode, _ = http_helper.HttpGet(t, minio_url, nil)
	// assert.Equal(t, statusCode, 200)
}
