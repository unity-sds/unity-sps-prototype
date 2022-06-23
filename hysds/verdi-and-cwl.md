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

## Step 2: Start the HySDS cluster on local laptop
```
cd unity-sps-prototype/hysds
./deploy.sh --all
```

## Step 3: Enter the Verdi container
Wait untill the HySDS cluster is completely up, then identify and enter the Verdi pod.
```
kubectl get pods
...
verdi-5fc5645cb5-lkbp4                2/2     Running     0          61s
...

kubectl exec -it verdi-5fc5645cb5-lkbp4 -c verdi bash

cd /src
```

## Step 4: Update the input parameters used by the CWL workflow

Edit the parameter file ssips_L1b_workflow.yml, replace the values of:
* aws_access_key_id
* aws_secret_access_key
* aws_session_token
with the new values from the file ~/.aws/credentials on your laptop (from the 'saml-pub' profile).
