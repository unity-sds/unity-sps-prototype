#!/bin/sh

#### validate terraform and deploy

terraform fmt

CLUSTER_NAME=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9')

terraform workspace new $CLUSTER_NAME

if [[ ! $(echo $?) -eq 0 ]]
then
    echo "Failed to create new workspace for $CLUSTER_NAME"
    exit 1
fi

terraform init

if [[ ! $(echo $?) -eq 0 ]]
then
    echo "Failed to init terraform modules for $CLUSTER_NAME"
    exit 1
fi

terraform apply -auto-approve -var "cluster_name=$CLUSTER_NAME"

if [[ ! $(echo $?) -eq 0 ]]
then
    echo "Failed to apply terraform for $CLUSTER_NAME"
    exit 1
fi

#### validate k8s deployment

aws eks update-kubeconfig --region us-west-2 --name $CLUSTER_NAME --kubeconfig ./temp_kube_cfg

if [[ ! $(echo $?) -eq 0 ]]
then
    echo "Failed to get config for $CLUSTER_NAME"
    exit 1
fi

OLD_CFG=$(echo $KUBECONFIG)
export KUBECONFIG=./temp_kube_cfg

# validates that the API is reachable and user has permissions
kubectl get all -A

if [[ ! $(echo $?) -eq 0 ]]
then
    echo "Failed to execute (kubectl get all -A), is the cluster reachable?"
    exit 1
fi

terraform destroy -auto-approve -var "cluster_name=$CLUSTER_NAME"

if [[ ! $(echo $?) -eq 0 ]]
then
    echo "Failed to destroy cluster $CLUSTER_NAME"
    exit 1
fi

rm $KUBECONFIG
export KUBECONFIG=$OLD_CFG