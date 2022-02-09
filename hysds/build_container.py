import sys
import os
import json
import argparse
import subprocess
import requests
import jsonschema


__MOZART_REST_API = "http://localhost:8888/api/v0.1"
__GRQ_REST_API = "http://localhost:8878/api/v0.1"


def build_image(tag):
    """
    Builds the Docker image
    :param tag: str; example, hello_world:develop
    :return: int; return status of docker build command
    """
    if ':' not in tag:
        tag = '%s:develop' % tag

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
    print(' '.join(command))
    process = subprocess.Popen(command, stdout=subprocess.PIPE)

    for c in iter(lambda: process.stdout.read(1), b''):
        sys.stdout.buffer.write(c)
        print(c)
    return process.poll()


def build_container_name(path, version="develop"):
    if path.endswith('/'):
        path = path[:-1]
    print("path", path)
    container = path.split('/')[-1]
    container = 'container-%s:%s' % (container, version.lower())
    print("container", container)
    return container


def build_job_spec_name(file_name, version="develop"):
    """
    :param file_name:
    :param version:
    :return: str, ex. job-hello_world:develop
    """
    name = file_name.split('.')[-1]
    job_name = 'job-%s:%s' % (name, version)
    return job_name


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
            validator = jsonschema.Draft7Validator(schema)
            errors = sorted(validator.iter_errors(d), key=lambda e: e.path)
            if len(errors) > 0:
                raise RuntimeError("JSON schema failed to validate; errors: {}".format(errors))


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
    for p in filter(lambda x: x.startswith("job-spec"), os.listdir(fps)):
        with open(os.path.join(fps, p), 'r') as f:
            d = json.load(f)
            validator = jsonschema.Draft7Validator(schema)
            errors = sorted(validator.iter_errors(d), key=lambda e: e.path)
            if len(errors) > 0:
                raise RuntimeError("JSON schema failed to validate; errors: {}".format(errors))


def publish_container(path, repository, version="develop", dry_run=False):
    """
    :param path:
    :param repository:
    :param version:
    :param dry_run:
    :return:
    """
    command = ["docker", "inspect", "%s:%s" % (repository, version)]
    process = subprocess.run(command, stdout=subprocess.PIPE)
    image_info = json.loads(process.stdout)
    digest = image_info[0]['Id']
    metadata = {
        "name": build_container_name(path, version.lower()),
        "version": version,
        "url": "placeholder",
        "digest": digest,
        "resource": "container",
    }
    print("container: ", json.dumps(metadata, indent=2))
    if dry_run is False:
        add_container_endpoint = os.path.join(__MOZART_REST_API, "container/add")
        r = requests.post(add_container_endpoint, data=metadata, verify=False)
        print(r.text)
        r.raise_for_status()


def publish_job_spec(path, version="develop", dry_run=False):
    """
    :param path:
    :param version:
    :param dry_run:
    :return:
    """
    container = build_container_name(path, version.lower())
    fps = os.path.join(path, "docker")
    for p in filter(lambda x: x.startswith("job-spec"), os.listdir(fps)):
        metadata = dict()
        metadata["container"] = container
        metadata["job-version"] = version
        metadata["resource"] = "jobspec"
        metadata["id"] = build_job_spec_name(p, version)
        with open(os.path.join(fps, p)) as f:
            job_spec = json.loads(f.read())
            metadata = {**metadata, **job_spec}
            print("job_specs: ", json.dumps(metadata, indent=2))
            if dry_run is False:
                endpoint = os.path.join(__MOZART_REST_API, "job_spec/add")
                r = requests.post(endpoint, data={"spec": json.dumps(metadata)}, verify=False)
                print(r.text)
                r.raise_for_status()


def publish_hysds_io(path, version="develop", dry_run=False):
    """
    :param path:
    :param version:
    :param dry_run:
    :return:
    """
    fps = os.path.join(path, "docker")
    for p in filter(lambda x: x.startswith("hysds-io"), os.listdir(fps)):
        name = p.split('.')[-1]
        metadata = dict()
        metadata["job-specification"] = build_job_spec_name(name, version)
        metadata["job-version"] = version
        metadata["resource"] = "hysds-io-specification"
        metadata["id"] = "hysds-io-%s:%s" % (name, version)
        with open(os.path.join(fps, p)) as f:
            hysds_io = json.loads(f.read())
            metadata = {**metadata, **hysds_io}
            print("hysds-ios: ", json.dumps(metadata, indent=2))
            if dry_run is False:
                if metadata.get("component", "tosca") in ("mozart", "figaro"):
                    api_endpoint = os.path.join(__MOZART_REST_API, "hysds_io/add")
                else:
                    api_endpoint = os.path.join(__GRQ_REST_API, "hysds_io/add")
                data = {"spec": json.dumps(metadata)}
                r = requests.post(api_endpoint, data=data, verify=False)
                print(r.text)
                r.raise_for_status()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file-path")
    parser.add_argument("-i", "--image", required=True)
    parser.add_argument("--dry-run", action='store_true', default=False)

    args = parser.parse_args()
    file_path = os.path.abspath(args.file_path) or os.getcwd()
    image = args.image
    dry_run = args.dry_run

    print("Building from %s..." % file_path)

    if not image.startswith("container-"):
        image = "container-%s" % image

    pwd = os.getcwd()
    os.chdir(file_path)

    validate_hysds_ios(file_path)
    validate_job_specs(file_path)

    build_image_status = build_image(image)
    if build_image_status != 0:
        raise RuntimeError("Failed to build docker image")

    image_split = image.split(':')
    repo = image_split[0]
    _version = image_split[-1] if len(image_split) > 1 else 'develop'

    publish_job_spec(file_path, _version, dry_run=dry_run)
    publish_hysds_io(file_path, _version, dry_run=dry_run)
    publish_container(file_path, repo, _version, dry_run=dry_run)
