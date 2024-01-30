#!/bin/sh

#### validate terraform and deploy

terraform fmt

CLUSTER_NAME=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9')

terraform workspace new $CLUSTER_NAME

terraform init

terraform apply -auto-approve -var "cluster_name=$CLUSTER_NAME"

#### validate k8s deployment

aws eks update-kubeconfig --region us-west-2 --name $CLUSTER_NAME --kubeconfig ./temp_kube_cfg

OLD_CFG=$(echo $KUBECONFIG)
export KUBECONFIG=./temp_kube_cfg

# validates that the API is reachable and user has permissions
kubectl get all -A

terraform destroy -auto-approve -var "cluster_name=$CLUSTER_NAME"

rm $KUBECONFIG
export KUBECONFIG=$OLD_CFG