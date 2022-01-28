#!/bin/bash

set -e

command=kubectl
mozart=0
grq=0
factotum=0

docstring() {
  cat << EOF
Usage:
  Deploys the HySDS cluster in Kubernetes (Elasticsearch, Rest API, RabbitMQ, Redis, etc.)
  $0 [--docker] [mozart] [grq] [--all]
  Options:
    --docker : use if running Kubernetes on Docker for Desktop; kubectl vs kubectl.docker
    --all : deploy both Mozart and GRQ cluster
    mozart : deploy Mozart cluster
    grq : deploy GRQ cluster
    factotum : deploy factotum
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
  echo "ERROR: Please specify [mozart|grq|--all] to deploy"
  exit 1
fi

$command delete cm celeryconfig || true
$command create cm celeryconfig --from-file ./celeryconfig.py


if (($mozart==1)) ; then
  $command delete cm mozart-settings || true
  $command create cm mozart-settings --from-file ./mozart/rest_api/settings.cfg

  $command delete cm logstash-configs || true
  $command create cm logstash-configs \
    --from-file=job-status=./mozart/logstash/job_status.template.json \
    --from-file=event-status=./mozart/logstash/event_status.template.json \
    --from-file=worker-status=./mozart/logstash/worker_status.template.json \
    --from-file=task-status=./mozart/logstash/task_status.template.json \
    --from-file=logstash-conf=./mozart/logstash/logstash.conf \
    --from-file=logstash-yml=./mozart/logstash/logstash.yml
  
  helm repo add elastic https://helm.elastic.co
  helm install --wait mozart-es elastic/elasticsearch --version 7.9.3 -f ./mozart/elasticsearch/values-override.yml

  $command apply -f ./mozart/rest_api/deployment.yml
  $command apply -f ./mozart/redis/deployment.yml
  $command apply -f ./mozart/logstash/deployment.yml
  $command apply -f ./mozart/rabbitmq/deployment.yml
  $command apply -f ./mozart/celery/deployment.yml
fi

if (($grq==1)) ; then
  $command delete cm grq2-settings || true
  $command create cm grq2-settings --from-file ./grq/rest_api/settings.cfg

  helm repo add elastic https://helm.elastic.co
  helm install --wait grq-es elastic/elasticsearch --version 7.9.3 -f ./grq/elasticsearch/values-override.yml

  $command apply -f ./grq/rest_api/deployment.yml
fi

if (($factotum==1)) ; then
  $command delete cm datasets || true
  $command create cm datasets --from-file ./factotum/datasets.json || true

  $command delete cm supervisord-job-worker || true
  $command create cm supervisord-job-worker --from-file ./factotum/supervisord.conf || true

  $command apply -f ./factotum/deployment.yml
fi
