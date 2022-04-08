#!/bin/bash

set -e

command=kubectl
mozart=0
grq=0
factotum=0

docstring() {
  cat <<EOF
Usage:
  Tear down the HySDS cluster in Kubernetes
  $0 [--docker] [mozart] [grq] [--all]
  Options:
    --all : destroy all HySDS resources (Mozart + GRQ + factotum)
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

if (($grq == 0 && $mozart == 0 && $factotum == 0)); then
  echo "ERROR: Please specify [mozart|grq|--all] to destroy"
  exit 1
fi

if (($mozart == 1)); then
  kubectl delete -f ./mozart/rest_api/deployment.yml || true
  kubectl delete -f ./mozart/redis/deployment.yml || true
  kubectl delete -f ./mozart/logstash/deployment.yml || true
  kubectl delete -f ./mozart/rabbitmq/deployment.yml || true
  kubectl delete -f ./ui/deployment.yml || true
  kubectl delete cm mozart-settings || true
  kubectl delete cm logstash-configs || true

  helm uninstall mozart-es || true
  kubectl get pvc --no-headers=true | awk '/mozart-es/{print $1}' | xargs kubectl delete pvc || true
fi

if (($grq == 1)); then
  kubectl delete cm grq2-settings || true
  kubectl delete -f ./grq/rest_api/deployment.yml || true

  helm uninstall grq-es || true
  kubectl get pvc --no-headers=true | awk '/grq-es/{print $1}' | xargs kubectl delete pvc || true
fi

if (($factotum == 1)); then
  kubectl delete -f ./factotum/deployment.yml || true
  kubectl delete -f ./verdi/deployment.yml
  kubectl delete -f ./orchestrator/deployment.yml || true
  kubectl delete -f ./user_rules/deployment.yml || true
  kubectl delete -f ./minio/deployment.yml || true
  kubectl delete -f ./minio/post-setup.yml || true
  kubectl delete -f ./minio/volume.yml || true

  kubectl delete cm datasets || true
  kubectl delete cm supervisord-job-worker || true
  kubectl delete cm supervisord-verdi || true
  kubectl delete cm supervisord-orchestrator || true
  kubectl delete cm supervisord-user-rules || true
fi

if (($mozart == 1 && $factotum == 1 && $grq == 1)); then
  kubectl delete cm celeryconfig || true
  kubectl delete cm netrc || true
  kubectl delete cm aws-credentials || true
fi
