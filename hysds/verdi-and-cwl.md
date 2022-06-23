# INSTRUCTIONS FOR EXECUTING THE SOUNDER SIPS L1B PGE AS CWL WORKFLOW ON A VERDI WORKER

## Pre-Requisites
* Clone this repository, check out the branch 'verdi-and-cwl'
* Clone the repository 'unity-sps-workflows', check out the branch 'main' or 'devel'

## Step 1: Build the Verdi Docker image with CWL libraries
"""
cd unity-sps-prototype/hysds
./build_images.sh 
"""

Verify that the Docker image 'verdi:unity-v0.0.1' has just been build on your laptop.
