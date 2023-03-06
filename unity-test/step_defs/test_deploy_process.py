from pytest_bdd import given, when, then, parsers, scenario
from .conftest import FEATURES_DIR, _process_skip_determination, reader
from urllib.parse import urljoin
import requests

feature_file = "deploy_process.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE, "Request deployment of a currently undeployed algorithm process"
)
def test_request_deployment_of_algorithm_process():
    pass


@given(
    parsers.parse(
        "the {project_name} {process_name} algorithm process is currently undeployed"
    ),
    target_fixture="project_process_dict",
)
def process_is_undeployed(
    process_service_endpoint, project_name, process_name, user_selected_processes
):
    _process_skip_determination(project_name, process_name, user_selected_processes)
    url = urljoin(process_service_endpoint, "processes")
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    assert "processes" in response_json
    processes = response_json["processes"]

    deployed = False
    for process in processes:
        deployed_process_name = process["id"].split(":")[0]
        if process_name.casefold() == deployed_process_name.casefold():
            deployed = True
            break

    assert not deployed

    project_process_dict = dict(project_name=project_name, process_name=process_name)
    return project_process_dict


@given("the proper JSON data for the POST request body", target_fixture="request_body")
def proper_json_data_post_request_body(project_process_dict):
    return reader.request_body(
        project_process_dict["project_name"],
        project_process_dict["process_name"],
        reader.deploy_post_request_body,
    )


@when(
    "a POST request is called on the WPS-T processes endpoint",
    target_fixture="response",
)
def post_processes(process_service_endpoint, request_body):
    url = urljoin(process_service_endpoint, "processes")
    deploy_process_response = requests.post(url, json=request_body)
    deploy_process_response.raise_for_status()
    return deploy_process_response


@then("the HTTP response body contains a DeploymentResult")
def response_contains_deployment_results(response):
    response_json = response.json()
    assert "deploymentResult" in response_json
