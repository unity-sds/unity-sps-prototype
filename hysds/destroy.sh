#!/bin/bash

set -e

command=kubectl
mozart=0
grq=0
factotum=0

docstring() {
  cat << EOF
Usage:
  Tear down the HySDS cluster in Kubernetes
  $0 [--docker] [mozart] [grq] [--all]
  Options:
    --docker : use if running Kubernetes on Docker for Desktop; kubectl vs kubectl.docker
    --all : destroy both Mozart and GRQ cluster
    mozart : destroy mozart cluster
    grq : destroy GRQ cluster
    factotum : destroy factotum
EOF
}

while [ "$1" != "" ]; do
  case $1 in
  -h | --help)
    docstring # run docstring function
    exit 0
    ;;
  --docker)
    command=kubectl.docker
    ;;
  -a | --all)
    mozart=1
    grq=1
    factotum=1
    ;;
  mozart)
    mozart=1
    ;;
  grq)
    grq=1
    ;;
  factotum)
    factotum=1
    ;;
  *)
    # exit 1
    ;;
  esac
  shift # remove the current value for `$1` and use the next
done


if (($grq==0 && $mozart==0 && $factotum==0)) ; then
  echo "ERROR: Please specify [mozart|grq|--all] to destroy"
  exit 1
fi

if (($mozart==1)) ; then
  helm uninstall mozart-es || true

  $command delete -f ./mozart/rest_api/deployment.yml || true
  $command delete -f ./mozart/redis/deployment.yml || true
  $command delete -f ./mozart/logstash/deployment.yml || true
  $command delete -f ./mozart/rabbitmq/deployment.yml || true
  $command delete -f ./mozart/celery/deployment.yml || true
  $command delete cm mozart-settings || true
  $command delete cm logstash-configs || true

  $command get pvc --no-headers=true | awk '/mozart-es/{print $1}' | xargs  kubectl delete pvc || true
fi

if (($grq==1)) ; then
  helm uninstall grq-es || true

  $command delete cm grq2-settings || true
  $command delete -f ./grq/rest_api/deployment.yml || true

  $command get pvc --no-headers=true | awk '/grq-es/{print $1}' | xargs  kubectl delete pvc || true
fi

if (($factotum==1)) ; then
  $command delete -f ./factotum/deployment.yml || true

  $command delete cm datasets || true
  $command delete cm supervisord-job-worker || true
fi
