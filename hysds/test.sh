#!/bin/bash

set -e

hysds_io_grq=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/hysds_ios.mapping)
curl -X PUT -H 'Content-Type: application/json' "http://localhost:9200/hysds_ios-grq?pretty" \
  -d "${hysds_io_grq}"

user_rules_grq=$(curl -s https://raw.githubusercontent.com/hysds/grq2/develop/config/user_rules_dataset.mapping)
curl -X PUT -H 'Content-Type: application/json' "http://localhost:9200/user_rules-grq?pretty" \
  -d "${user_rules_grq}"
