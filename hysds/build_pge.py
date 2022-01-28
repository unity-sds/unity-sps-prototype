import sys
import os
import json
import argparse
import subprocess
import requests
import jsonschema

"""
TODO:
    - build docker image
    - validate hysds-ios and job_specs schema
    - write specs to Elasticsearch
    - write container info to Elasticsearch
"""


def build_image(tag):
    """
    Builds the Docker image
    :param tag: str; example, hello_world:develop
    :return: int; return status of docker build command
    """
    command = [
        "docker",
        "build",
        ".",
        "-t",
        tag,
        "-f",
        "docker/Dockerfile",
        "--progress",
        "plain"
    ]
    process = subprocess.Popen(command, stdout=subprocess.PIPE)

    for c in iter(lambda: process.stdout.read(1), b""):
        sys.stdout.buffer.write(c)
        print(c)
    return process.poll()
  

def validate_hysds_ios(path):
    """
    Validates every hysds-io file in docker/ against the schema
    :param path:
    :return:
    """
    hysds_ios_schema = "https://raw.githubusercontent.com/hysds/hysds_commons/develop/schemas/hysds-io-schema.json"
    resp = requests.get(hysds_ios_schema)
    schema = resp.json()

    fps = os.path.join(path, "docker")
    for p in filter(lambda x: x.startswith("hysds-io"), os.listdir(fps)):
        with open(os.path.join(fps, p), 'r') as f:
            d = json.load(f)
            jsonschema.validate(d, schema)


def validate_job_specs(path):
    """
    Validates every job-spec file in docker/ against the schema
    :param path:
    :return:
    """
    job_spec_schema = "https://raw.githubusercontent.com/hysds/hysds_commons/develop/schemas/job-spec-schema.json"
    resp = requests.get(job_spec_schema)
    schema = resp.json()

    fps = os.path.join(path, "docker")
    for p in filter(lambda x: x.startswith("jo-spec"), os.listdir(fps)):
        with open(os.path.join(fps, p), 'r') as f:
            d = json.load(f)
            jsonschema.validate(d, schema)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file-path")
    parser.add_argument("-t", "--tag", required=True)

    args = parser.parse_args()
    file_path = args.file_path or os.getcwd()
    tag = args.tag

    pwd = os.getcwd()
    os.chdir(file_path)

    validate_hysds_ios(file_path)
    validate_job_specs(file_path)

    build_image_status = build_image(tag)
    if build_image_status != 0:
        raise RuntimeError("Failed to build docker image")
