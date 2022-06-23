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

First, edit the file verdi/deployment.yml and replace the locations for 'static-data' and 'src-dir' with the proper values from your local laptop.

TO DO: Add a generic Kubernetes Peristent Volume to the HySDS cluster where each project can store their static data.

TO DO: Remove the referece to the local source directory and check out the CWL workflow during the HySDS deployment instead.

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

## Step 5: Execute the L1B CWL workflow

```
cwl-runner --no-read-only ssips_L1b_workflow.cwl ssips_L1b_workflow.yml

INFO /home/ops/miniconda3/bin/cwl-runner 3.1.20220607081835
INFO Resolved 'ssips_L1b_workflow.cwl' to 'file:///src/ssips_L1b_workflow.cwl'
ssips_L1b_workflow.cwl:12:3: Warning: checking item
                             Warning:   Field `class` contains undefined reference to
                             `http://commonwl.org/cwltool#Secrets`
INFO ssips_L1b_workflow.cwl:1:1: Unknown hint http://commonwl.org/cwltool#Secrets
utils/download_dir_from_s3.cwl:11:3: Warning: checking item
                                     Warning:   Field `class` contains undefined reference to
                                     `http://commonwl.org/cwltool#Secrets`
INFO utils/download_dir_from_s3.cwl:1:1: Unknown hint http://commonwl.org/cwltool#Secrets
utils/upload_dir_to_s3.cwl:12:3: Warning: checking item
                                 Warning:   Field `class` contains undefined reference to
                                 `http://commonwl.org/cwltool#Secrets`
utils/upload_dir_to_s3.cwl:49:3: object id `utils/upload_dir_to_s3.cwl#target_s3_folder` previously defined
INFO utils/upload_dir_to_s3.cwl:1:1: Unknown hint http://commonwl.org/cwltool#Secrets
WARNING Workflow checker warning:
ssips_L1b_workflow.cwl:81:7: 'static_dir' is not an input parameter of file:///src/l1b_package.cwl,
                             expected input_dir
INFO [workflow ] start
INFO [workflow ] starting step l1b-stage-in
INFO [step l1b-stage-in] start
INFO ['docker', 'pull', 'pymonger/aws-cli']
Using default tag: latest
latest: Pulling from pymonger/aws-cli
a0d0a0d46f8b: Pull complete 
a37cadeb7c5f: Pull complete 
Digest: sha256:2b57719a568ce46705402dbece5b5a85394e128b8201d1dbba7d983a3f0936ed
Status: Downloaded newer image for pymonger/aws-cli:latest
INFO [job l1b-stage-in] /tmp/mzf6gtpm$ docker \
    run \
    -i \
    --mount=type=bind,source=/tmp/mzf6gtpm,target=/zTafSk \
    --mount=type=bind,source=/tmp/eg0qjwoc,target=/tmp \
    --workdir=/zTafSk \
    --log-driver=none \
    --user=1000:1000 \
    --rm \
    --cidfile=/tmp/t7o_kq3b/20220623112851-832896.cid \
    --env=TMPDIR=/tmp \
    --env=HOME=/zTafSk \
    pymonger/aws-cli \
    aws \
    s3 \
    cp \
    --recursive \
    s3://unity-sps/sounder_sips/l1b/in \
    in > /tmp/mzf6gtpm/stdout_download_dir_from_s3.txt 2> /tmp/mzf6gtpm/stderr_download_dir_from_s3.txt
INFO [job l1b-stage-in] Max memory used: 223MiB
INFO [job l1b-stage-in] completed success
INFO [step l1b-stage-in] completed success
INFO [workflow ] starting step l1b-run-pge
INFO [step l1b-run-pge] start
INFO [workflow l1b-run-pge] start
INFO [workflow l1b-run-pge] starting step l1b_process
INFO [step l1b_process] start
INFO ['docker', 'pull', 'lucacinquini/sounder_sips_l1b_pge:r0.1.0']
r0.1.0: Pulling from lucacinquini/sounder_sips_l1b_pge
2d473b07cdd5: Pull complete 
7c3e67e56779: Pull complete 
68ad918dc9f9: Pull complete 
d3c28fe3fec9: Pull complete 
fbf37da0047a: Pull complete 
ca452edb93af: Pull complete 
4a00ac08ebae: Pull complete 
8c50bd867e7f: Pull complete 
803a69dada6b: Pull complete 
36de86821855: Pull complete 
cd3878d038ce: Pull complete 
0c49c57d13bd: Pull complete 
a2a6c9b0db0e: Pull complete 
28a614503bca: Pull complete 
c5fa82e72262: Pull complete 
647b0487a5d9: Pull complete 
398f54925685: Pull complete 
b08fa59cb4f6: Pull complete 
5cb467f1bb48: Pull complete 
00a13f82b87e: Pull complete 
5b909f2e0bd9: Pull complete 
Digest: sha256:799cb6455083ffb212ff0dba825149af9a827ba9113d65871de9126e4eb094bf
Status: Downloaded newer image for lucacinquini/sounder_sips_l1b_pge:r0.1.0
INFO [job l1b_process] /tmp/j86eeriy$ docker \
    run \
    -i \
    --mount=type=bind,source=/tmp/j86eeriy,target=/zTafSk \
    --mount=type=bind,source=/tmp/xjr76hq2,target=/tmp \
    --mount=type=bind,source=/tmp/mzf6gtpm/in,target=/var/lib/cwl/stge22afe10-2ce1-43da-8dd7-f01f1fa11a6d/in,readonly \
    --workdir=/zTafSk \
    --log-driver=none \
    --user=1000:1000 \
    --rm \
    --cidfile=/tmp/bq_7n8g5/20220623112922-037693.cid \
    --env=TMPDIR=/tmp \
    --env=HOME=/zTafSk \
    lucacinquini/sounder_sips_l1b_pge:r0.1.0 \
    /zTafSk/processed_notebook.ipynb \
    -p \
    input_path \
    /var/lib/cwl/stge22afe10-2ce1-43da-8dd7-f01f1fa11a6d/in \
    -p \
    output_path \
    /zTafSk > /tmp/j86eeriy/l1b_pge_stdout.txt 2> /tmp/j86eeriy/l1b_pge_stderr.txt
INFO [job l1b_process] Max memory used: 221MiB
INFO [job l1b_process] completed success
INFO [step l1b_process] completed success
INFO [workflow l1b-run-pge] completed success
INFO [step l1b-run-pge] completed success
INFO [workflow ] starting step l1b-stage-out
INFO [step l1b-stage-out] start
INFO [job l1b-stage-out] /tmp/96208f3g$ docker \
    run \
    -i \
    --mount=type=bind,source=/tmp/96208f3g,target=/zTafSk \
    --mount=type=bind,source=/tmp/3k4_suz8,target=/tmp \
    --mount=type=bind,source=/tmp/j86eeriy,target=/zTafSk/j86eeriy,readonly \
    --workdir=/zTafSk \
    --log-driver=none \
    --user=1000:1000 \
    --rm \
    --cidfile=/tmp/33mxb81w/20220623112953-937361.cid \
    --env=TMPDIR=/tmp \
    --env=HOME=/zTafSk \
    pymonger/aws-cli \
    aws \
    s3 \
    cp \
    --recursive \
    j86eeriy \
    s3://unity-sps/sounder_sips/l1b/out/j86eeriy > /tmp/96208f3g/upload_dir_to_s3_stdout.txt 2> /tmp/96208f3g/upload_dir_to_s3_stderr.txt
INFO [job l1b-stage-out] Max memory used: 48MiB
INFO [job l1b-stage-out] completed success
INFO [step l1b-stage-out] completed success
INFO [workflow ] completed success
{
    "output_target_s3_folder": "s3://unity-sps/sounder_sips/l1b/out",
    "output_target_s3_subdir": "j86eeriy",
    "stderr_l1b-run-pge": {
        "location": "file:///src/l1b_pge_stderr.txt",
        "basename": "l1b_pge_stderr.txt",
        "class": "File",
        "checksum": "sha1$b3dc445c6a38059ada09f4c706d2e8e10a59ca49",
        "size": 1273,
        "path": "/src/l1b_pge_stderr.txt"
    },
    "stderr_l1b-stage-in": {
        "location": "file:///src/stderr_download_dir_from_s3.txt",
        "basename": "stderr_download_dir_from_s3.txt",
        "class": "File",
        "checksum": "sha1$da39a3ee5e6b4b0d3255bfef95601890afd80709",
        "size": 0,
        "path": "/src/stderr_download_dir_from_s3.txt"
    },
    "stderr_stage-out": {
        "location": "file:///src/upload_dir_to_s3_stderr.txt",
        "basename": "upload_dir_to_s3_stderr.txt",
        "class": "File",
        "checksum": "sha1$da39a3ee5e6b4b0d3255bfef95601890afd80709",
        "size": 0,
        "path": "/src/upload_dir_to_s3_stderr.txt"
    },
    "stdout_l1b-run-pge": {
        "location": "file:///src/l1b_pge_stdout.txt",
        "basename": "l1b_pge_stdout.txt",
        "class": "File",
        "checksum": "sha1$9e81d7e57cf5415034394b7c90d8c25a9ec949dc",
        "size": 389441,
        "path": "/src/l1b_pge_stdout.txt"
    },
    "stdout_l1b-stage-in": {
        "location": "file:///src/stdout_download_dir_from_s3.txt",
        "basename": "stdout_download_dir_from_s3.txt",
        "class": "File",
        "checksum": "sha1$8665855dfff078dd330dd612d2551a73c79b59a0",
        "size": 53162,
        "path": "/src/stdout_download_dir_from_s3.txt"
    },
    "stdout_stage-out": {
        "location": "file:///src/upload_dir_to_s3_stdout.txt",
        "basename": "upload_dir_to_s3_stdout.txt",
        "class": "File",
        "checksum": "sha1$ffb59cf72d596ca2bf432bffc3ac032e226e541c",
        "size": 36738,
        "path": "/src/upload_dir_to_s3_stdout.txt"
    }
}
INFO Final process status is success

```

