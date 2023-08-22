#!/bin/bash
mkdir $WORKDIR/k8s
aws eks update-kubeconfig --name $NAME --kubeconfig $WORKDIR/k8s/kubernetes.yml
