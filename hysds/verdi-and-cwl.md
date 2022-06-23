# INSTRUCTIONS FOR EXECUTING THE SOUNDER SIPS L1B PGE AS CWL WORKFLOW ON A VERDI WORKER

## Pre-Requisites
* Clone this repository, check out the branch 'verdi-and-cwl'
* Clone the repository 'unity-sps-workflows', check out the branch 'main' or 'devel'
* Copy the L1B static data from AWS S3 to a local directory:
```
aws-login -pub
jpl-mipl
power_user---------------------> arn:aws:iam::XXXXXXXXXXXXXXXXX:role/power_user

cd <any_local_directory>
aws s3 cp s3://unity-sps/sounder_sips/l1b/in/ . --recursive
```

## Step 1: Build the Verdi Docker image with CWL libraries
```
cd unity-sps-prototype/hysds
./build_images.sh 
```

Verify that the Docker image 'verdi:unity-v0.0.1' has just been build on your laptop.
