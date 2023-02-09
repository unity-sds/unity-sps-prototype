#!/bin/bash

set -e

mozart=0
grq=0
factotum=0

docstring() {
  cat <<EOF
Usage:
  Deploys the HySDS cluster in Kubernetes (Elasticsearch, Rest API, RabbitMQ, Redis, etc.)
  $0 [--docker] [mozart] [grq] [--all]
  Options:
    --all : deploy all HySDS resources (Mozart + GRQ + factotum)
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
  echo "ERROR: Please specify [mozart|grq|--all] to deploy"
  exit 1
fi

kubectl delete cm celeryconfig || true
kubectl create cm celeryconfig --from-file ./configs/celeryconfig.py

kubectl delete cm netrc || true
kubectl create cm netrc --from-file ./configs/.netrc

kubectl delete cm aws-credentials || true
kubectl create cm aws-credentials --from-file ./configs/aws-credentials

helm repo add elastic https://helm.elastic.co

if (($mozart == 1)); then
  kubectl delete cm mozart-settings || true
  kubectl create cm mozart-settings --from-file ./mozart/rest_api/settings.cfg

  kubectl delete cm logstash-configs || true
  kubectl create cm logstash-configs \
    --from-file=job-status=./mozart/logstash/job_status.template.json \
    --from-file=event-status=./mozart/logstash/event_status.template.json \
    --from-file=worker-status=./mozart/logstash/worker_status.template.json \
    --from-file=task-status=./mozart/logstash/task_status.template.json \
    --from-file=logstash-conf=./mozart/logstash/logstash.conf \
    --from-file=logstash-yml=./mozart/logstash/logstash.yml

  helm repo add elastic https://helm.elastic.co
  helm install --wait --timeout 150s mozart-es elastic/elasticsearch --version 7 -f ./mozart/elasticsearch/values-override.yml

  mozart_es_template=$(curl -s https://raw.githubusercontent.com/hysds/mozart/develop/configs/es_template.json)
  for idx in "containers" "job_specs" "hysds_io"; do
    template=$(echo ${mozart_es_template} | sed "s/{{ index }}/${idx}/")
    echo "writing template: ${idx}"
    curl -s -X PUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/_template/${idx}' -d "${template}" >/dev/null
  done

  hysds_io_mozart=$(curl -s https://raw.githubusercontent.com/hysds/mozart/develop/configs/hysds_ios.mapping)
  curl -X PUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/hysds_ios-mozart?pretty' -d "${hysds_io_mozart}"

  user_rules_mozart=$(curl -s https://raw.githubusercontent.com/hysds/mozart/develop/configs/user_rules_job.mapping)
  curl -X PUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/user_rules-mozart?pretty' -d "${user_rules_mozart}"

  hysds_io_grq=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/hysds_ios.mapping)
  curl -X PUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/hysds_ios-grq?pretty' -d "${hysds_io_grq}"

  user_rules_grq=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/user_rules_dataset.mapping)
  curl -X PUT -H 'Content-Type: application/json' 'http://127.0.0.1:9200/user_rules-grq?pretty' -d "${user_rules_grq}"

  kubectl apply -f ./mozart/rest_api/deployment.yml
  kubectl apply -f ./mozart/redis/deployment.yml
  kubectl apply -f ./mozart/logstash/deployment.yml
  kubectl apply -f ./mozart/rabbitmq/deployment.yml
  kubectl apply -f ./ui/deployment.yml
fi

if (($grq == 1)); then
  kubectl delete cm grq2-settings || true
  kubectl create cm grq2-settings --from-file ./grq/rest_api/settings.cfg

  helm repo add elastic https://helm.elastic.co
  helm install --wait --timeout 150s grq-es elastic/elasticsearch --version 7 -f ./grq/elasticsearch/values-override.yml

  grq_es_template=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/es_template.json)
  template=$(echo ${grq_es_template} | sed 's/{{ prefix }}/grq/;s/{{ alias }}/grq/')
  echo "writing template: grq"
  curl -s -X PUT -H 'Content-Type: application/json' 'http://127.0.0.1:9201/_template/grq' -d "${template}" >/dev/null

  ingest_pipeline=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/ingest_pipeline.json)
  curl -s -X PUT -H 'Content-Type: application/json' \
    'http://127.0.0.1:9201/_ingest/pipeline/dataset_pipeline' -d "${ingest_pipeline}" >/dev/null
  echo "writing ingest pipeline"

  kubectl apply -f ./grq/rest_api/deployment.yml
fi

if (($factotum == 1)); then
  mkdir -p /private/tmp/data || true
  kubectl apply -f ./minio/volume.yml
  sleep 5

  kubectl delete cm supervisord-orchestrator || true
  kubectl create cm supervisord-orchestrator --from-file ./orchestrator/supervisord.conf

  if [[ ! -f "./configs/datasets.json" ]]; then
    cp ./configs/datasets.template.json ./configs/datasets.json
  fi
  kubectl delete cm datasets || true
  kubectl create cm datasets --from-file ./configs/datasets.json

  if [[ ! -f "./verdi/supervisord.conf" ]]; then
    cp ./verdi/supervisord.template.conf ./verdi/supervisord.conf
  fi
  kubectl delete cm supervisord-verdi || true
  kubectl create cm supervisord-verdi --from-file ./verdi/supervisord.conf

  kubectl delete cm supervisord-job-worker || true
  kubectl create cm supervisord-job-worker --from-file ./factotum/supervisord.conf

  kubectl delete cm supervisord-user-rules || true
  kubectl create cm supervisord-user-rules --from-file ./user_rules/supervisord.conf

  kubectl apply -f ./orchestrator/deployment.yml
  kubectl apply -f ./user_rules/deployment.yml
  kubectl apply -f ./factotum/deployment.yml
  kubectl apply -f ./verdi/deployment.yml

  kubectl apply -f ./minio/deployment.yml
  kubectl apply -f ./minio/post-setup.yml
fi
