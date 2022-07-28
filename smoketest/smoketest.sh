#!/bin/sh
cd ../terraform-test/ && go test -v -run TestTerraformUnity -timeout 30m | tee terratest_output.txt
