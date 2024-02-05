#!/bin/sh
# Script to execute a CWL workflow that includes Docker containers
# The Docker engine is started before the CWL execution, and stopped afterwards.
# $1: the CWL workflow URL (example: https://raw.githubusercontent.com/unity-sds/unity-sps-prototype/cwl-docker/cwl/cwl_workflows/echo_from_docker.cwl)
# $2: the CWL job parameters as a JSON fomatted string (example: { name: John Doe })
set -ex
cwl_workflow=$1
job_args=$2
echo "Executing CWL workflow: $cwl_workflow with json arguments: $job_args"
echo $job_args > /tmp/job_args.json
cat /tmp/job_args.json

# Start Docker engine
dockerd &> dockerd-logfile &

# Wait until Docker engine is running
# Loop until 'docker version' exits with 0.
until docker version > /dev/null 2>&1
do
  sleep 1
done

# Execute CWL workflow
source /usr/share/cwl/venv/bin/activate
cwl-runner $cwl_workflow /tmp/job_args.json
deactivate

# Stop Docker engine
pkill -f dockerd





