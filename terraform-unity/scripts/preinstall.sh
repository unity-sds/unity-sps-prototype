#!/bin/bash
mkdir $WORKDIR/k8s
aws eks update-kubeconfig --name $EKS_NAME --kubeconfig $WORKDIR/k8s/kubernetes.yml
