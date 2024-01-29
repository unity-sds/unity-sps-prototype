#!/bin/sh
# Script to execute a CWL workflow that includes Docker containers
# The Docker engine is started before the CWL execution, and stopped afterwards.
set -ex
cwl_workflow=$1
echo "Executing CWL workflow: $cwl_workflow"

# Start Docker engine
dockerd &> dockerd-logfile &

# Wait until Docker engine is running
# Loop until 'docker version' exits with 0.
until docker version > /dev/null 2>&1
do
  sleep 1
done

# Execute CWL workflow
# docker run hello-world
source /usr/share/cwl/venv/bin/activate
cwl-runner $cwl_workflow
deactivate

# Stop Docker engine
pkill -f dockerd





