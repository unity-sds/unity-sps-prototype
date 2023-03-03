import pytest
from pytest_bdd import given, then
from pathlib import Path
import requests
from urllib.parse import urljoin
import json

TEST_BASE_DIR = Path(__file__).resolve().parents[1]
FEATURES_DIR = TEST_BASE_DIR.joinpath("features")
DATA_DIR = TEST_BASE_DIR.joinpath("data")


def pytest_addoption(parser):
    parser.addoption(
        "--process-service-endpoint",
        action="store",
        help="Base URL for the Process service endpoint",
    )
    parser.addoption(
        "--sps-api-service-endpoint",
        action="store",
        help="Base URL for the SPS API service endpoint",
    )


@pytest.fixture
def process_service_endpoint(request):
    return request.config.getoption("--process-service-endpoint")

@pytest.fixture
def sps_api_service_endpoint(request):
    return request.config.getoption("--sps-api-service-endpoint")


def undeploy_processes(process_service_endpoint):
    url = urljoin(process_service_endpoint, "/processes")
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    processes = response_json["processes"]

    for process in processes:
        url = urljoin(
            process_service_endpoint,
            f"/processes/{process['id']}:{process['processVersion']}",
        )
        undeploy_process_response = requests.delete(url)
        undeploy_process_response.raise_for_status()


def pytest_sessionstart(session):
    process_service_endpoint = session.config.getoption("--process-service-endpoint")
    undeploy_processes(process_service_endpoint)


def pytest_sessionfinish(session, exitstatus):
    process_service_endpoint = session.config.getoption("--process-service-endpoint")
    undeploy_processes(process_service_endpoint)


@pytest.fixture
def deploy_post_request_body():
    data_file_path = DATA_DIR.joinpath("deploy_post_request_body.json")

    with open(data_file_path) as f:
        data = json.load(f)
    return data

@pytest.fixture
def start_prewarm_post_request_body():
    data_file_path = DATA_DIR.joinpath("start_prewarm_post_request_body.json")

    with open(data_file_path) as f:
        data = json.load(f)
    return data

@pytest.fixture
def execution_post_request_body():
    data_file_path = DATA_DIR.joinpath("execution_post_request_body.json")

    with open(data_file_path) as f:
        data = json.load(f)
    return data


@given("the prewarm request has been created", target_fixture="request_id")
def prewarm_request_has_been_created(start_prewarm_post_request_body):
    url = urljoin(process_service_endpoint, "sps/prewarm")
    start_prewarm_response = requests.post(url, json=start_prewarm_post_request_body)
    start_prewarm_response.raise_for_status()
    return start_prewarm_response.json()["request_id"]

@then("the HTTP response body contains a request id")
def response_contains_request_id(response):
    response_json = response.json()
    assert "request_id" in response_json

@given("the SoundsSIPS L1B algorithm has been deployed to the ADES")
def l1b_deployed(process_service_endpoint, deploy_post_request_body):
    url = urljoin(process_service_endpoint, "processes")
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    assert "processes" in response_json
    processes = response_json["processes"]

    l1b_deployed = False
    for process in processes:
        if "l1b-cwl" in process["id"]:
            l1b_deployed = True
            break

    if not l1b_deployed:
        deploy_process_response = requests.post(url, json=deploy_post_request_body)
        deploy_process_response.raise_for_status()
        l1b_deployed = True

    assert l1b_deployed


@then("the HTTP response contains a successful status code")
def success_response(response):
    assert response.status_code <= 399

@then("the HTTP response contains a status code of 200")
def ok_response(response):
    assert response.status_code == 200

@then("the HTTP response contains a status code of 201")
def created_response(response):
    assert response.status_code == 201


def _request_job_execution(endpoint, request_body):
    url = urljoin(endpoint, "processes/l1b-cwl:develop/jobs")
    job_execution_response = requests.post(url, json=request_body)
    job_execution_response.raise_for_status()
    return job_execution_response


def _request_job_status_by_id(endpoint, job_id):
    url = urljoin(endpoint, f"/processes/l1b-cwl:develop/jobs/{job_id}")
    job_status_response = requests.get(url)
    job_status_response.raise_for_status()
    return job_status_response
