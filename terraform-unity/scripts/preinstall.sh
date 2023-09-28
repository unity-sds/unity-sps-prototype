#!/bin/bash
LOGFILE="/tmp/scriptlog.log"
exec > $LOGFILE 2>&1
set -x
mkdir $WORKDIR/k8s
aws eks update-kubeconfig --name $UNITY_EKS --kubeconfig $WORKDIR/k8s/kubernetes.yml
