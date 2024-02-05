#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool
hints:
  DockerRequirement:
    dockerPull: busybox:latest
baseCommand: ["echo"]

inputs:
  greeting:
    type: string
    default: "Hola"
    inputBinding:
      position: 1
  name:
    type: string
    default: "Mundo"
    inputBinding:
      position: 2
outputs: []

