#!/bin/bash

set -e

DIRNAME="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ARGS=$@

while [ "$1" != "" ]; do
  case $1 in
  -f | --file)
    echo "Can not use the -f/--file flag"
    exit 1
    ;;
  *)
    ;;
  esac
  shift # remove the current value for `$1` and use the next
done

cd ${DIRNAME}
docker build . -t hysds-core:unity-v0.0.1 ${ARGS}

cd ${DIRNAME}/mozart/rest_api
docker build . -t hysds-mozart:unity-v0.0.1 ${ARGS}

cd ${DIRNAME}/mozart/celery
docker build . -t celery-tasks:unity-v0.0.1 ${ARGS}

cd ${DIRNAME}/grq/rest_api
docker build . -t hysds-grq2:unity-v0.0.1 ${ARGS}

cd ${DIRNAME}/factotum
docker build . -t factotum:unity-v0.0.1 ${ARGS}

cd $(pwd)
