#!/bin/bash
mkdir $WORKDIR/k8s
aws eks update-kubeconfig --name $UNITY_EKS --kubeconfig $WORKDIR/k8s/kubernetes.yml
