#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: busybox:latest
baseCommand: ["echo", "Hello"]

inputs:
  name:
    type: string
    default: "World"
    inputBinding:
      position: 1
outputs: []

