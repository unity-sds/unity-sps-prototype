import pytest
from pytest_bdd import given, then, parsers
import requests
from urllib.parse import urljoin
import re
from . import TEST_BASE_DIR
from .utils import JsonReader


FEATURES_DIR = TEST_BASE_DIR.joinpath("features")
reader = JsonReader()


def pytest_addoption(parser):
    parser.addoption(
        "--process-service-endpoint",
        action="store",
        help="Base URL for the Process service endpoint",
        required=True,
    )
    parser.addoption(
        "--sps-api-service-endpoint",
        action="store",
        help="Base URL for the SPS API service endpoint",
    )
    parser.addoption(
        "--sounder-sips-process-selection",
        action="store",
        help="The Sounder SIPS processes to test (L1A, L1B, chirp)",
        required=True,
    )


@pytest.fixture(scope="module", autouse=True)
def process_service_endpoint(request):
    return request.config.getoption("--process-service-endpoint")


@pytest.fixture
def sps_api_service_endpoint(request):
    return request.config.getoption("--sps-api-service-endpoint")


@pytest.fixture
def projects():
    data = reader.request_body("", "", reader.projects)
    return data


@pytest.fixture
def user_selected_processes(request, projects):
    select_processes = dict()
    sounder_sips_proc_selection = request.config.getoption(
        "--sounder-sips-process-selection"
    )
    regex = re.compile(sounder_sips_proc_selection)
    select_processes["sounder_sips"] = list(
        filter(regex.match, projects["sounder_sips"]["processes"])
    )
    return select_processes


def _process_skip_determination(project_name, process_name, user_selected_processes):
    # regex = re.compile(request.param)
    # filtered_process_list = list(filter(regex.match, filtered_sounder_sips_processes))
    # if not filtered_process_list:
    #     pytest.skip(f"Test requires {request.param} to be selected")
    if process_name not in user_selected_processes[project_name]:
        pytest.skip(
            f"Test requires {project_name}'s {process_name} process to be selected"
        )


def _undeploy_all_processes(process_service_endpoint):
    url = urljoin(process_service_endpoint, "/processes")
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    processes = response_json["processes"]

    for process in processes:
        url = urljoin(
            process_service_endpoint,
            f"/processes/{process['id']}",
        )
        undeploy_process_response = requests.delete(url)
        undeploy_process_response.raise_for_status()


@pytest.fixture(scope="module", autouse=True)
def cleanup_fixture(process_service_endpoint):
    _undeploy_all_processes(process_service_endpoint)


def pytest_sessionstart(session):
    process_service_endpoint = session.config.getoption("--process-service-endpoint")
    _undeploy_all_processes(process_service_endpoint)


def pytest_sessionfinish(session, exitstatus):
    process_service_endpoint = session.config.getoption("--process-service-endpoint")
    _undeploy_all_processes(process_service_endpoint)


@pytest.fixture
def start_prewarm_post_request_body():
    project_name = "on_demand"
    request_body = reader.request_body(
        project_name, "", reader.start_prewarm_post_request_body
    )
    return request_body


@given("the prewarm request has been created", target_fixture="request_id")
def prewarm_request_has_been_created(
    sps_api_service_endpoint, start_prewarm_post_request_body
):
    url = urljoin(sps_api_service_endpoint, "sps/prewarm")
    start_prewarm_response = requests.post(url, json=start_prewarm_post_request_body)
    start_prewarm_response.raise_for_status()
    return start_prewarm_response.json()["request_id"]


@then("the HTTP response body contains a request id")
def response_contains_request_id(response):
    response_json = response.json()
    assert "request_id" in response_json


def _is_process_deployed(process_service_endpoint, process_name):
    deployed = False
    url = urljoin(process_service_endpoint, "processes")
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    assert "processes" in response_json
    processes = response_json["processes"]
    for process in processes:
        deployed_process_name = process["id"].split(":")[0]
        if process_name.casefold() == deployed_process_name.casefold():
            deployed = True
            break

    return deployed


def _deploy_process(process_service_endpoint, project_name, process_name):
    url = urljoin(process_service_endpoint, "processes")
    request_body = reader.request_body(
        project_name, process_name, reader.deploy_post_request_body
    )
    deploy_process_response = requests.post(url, json=request_body)
    deploy_process_response.raise_for_status()
    return deploy_process_response


@given(
    parsers.parse(
        "the {project_name} {process_name} algorithm process has been deployed to the ADES"
    ),
    target_fixture="project_process_dict",
)
def ensure_process_has_been_deployed(
    process_service_endpoint, project_name, process_name, user_selected_processes
):
    _process_skip_determination(project_name, process_name, user_selected_processes)

    deployed = _is_process_deployed(process_service_endpoint, process_name)
    if not deployed:
        response = _deploy_process(process_service_endpoint, project_name, process_name)
        if response.status_code == 201:
            deployed = True

    assert deployed

    project_process_dict = dict(project_name=project_name, process_name=process_name)
    return project_process_dict


@then("the HTTP response contains a successful status code")
def success_response(response):
    assert response.status_code <= 399


@then("the HTTP response contains a status code of 200")
def ok_response(response):
    assert response.status_code == 200


@then("the HTTP response contains a status code of 201")
def created_response(response):
    assert response.status_code == 201


@given(
    parsers.parse("a WPS-T request is made to execute the process"),
    target_fixture="response",
)
def request_job_execution(process_service_endpoint, project_process_dict):
    request_body = reader.request_body(
        project_process_dict["project_name"],
        project_process_dict["process_name"],
        reader.execution_post_request_body,
    )
    job_execution_response = _request_job_execution(
        process_service_endpoint, project_process_dict["process_name"], request_body
    )
    return job_execution_response


def _request_job_execution(endpoint, process_name, request_body):
    url = urljoin(endpoint, f"processes/{process_name.casefold()}:develop/jobs")
    job_execution_response = requests.post(url, json=request_body)
    job_execution_response.raise_for_status()
    return job_execution_response


def _request_job_status_by_id(endpoint, process_name, job_id):
    url = urljoin(
        endpoint,
        f"/processes/{process_name.casefold()}:develop/jobs/{job_id}",
    )
    job_status_response = requests.get(url)
    job_status_response.raise_for_status()
    return job_status_response


@given("the response includes a Location header", target_fixture="location_header")
def response_includes_location_header(response):
    assert "Location" in response.headers
    return response.headers["Location"]


@given("the Location header contains a job ID", target_fixture="job_id")
def location_header_contains_job_id(location_header):
    job_id = location_header.rsplit("/jobs/", 1)[-1]
    assert job_id
    return job_id
