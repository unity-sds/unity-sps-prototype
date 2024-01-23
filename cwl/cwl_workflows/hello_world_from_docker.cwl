#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool
# baseCommand: node
hints:
  DockerRequirement:
    dockerPull: hello-world:latest
#requirements:
#  EnvVarRequirement:
#    envDef:
#      HTTP_PROXY: tcp://docker-socket-proxy:2375
#      HTTPS_PROXY: tcp://docker-socket-proxy:2375

inputs: []
outputs: []

