from pytest_bdd import scenario, given, when, then
import requests
from urllib.parse import urljoin

from .conftest import FEATURES_DIR

feature_file = "deploy_process.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE, "Request deployment of the currently undeployed L1B algorithm process"
)
def test_request_deployment_of_the_l1b_algorithm_process():
    pass


@given("the L1B algorithm process is currently undeployed")
def l1b_process_is_undeployed(process_service_endpoint):
    url = urljoin(process_service_endpoint, "processes")
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    assert "processes" in response_json
    processes = response_json["processes"]

    l1b_deployed = False
    for process in processes:
        if "l1b_pge_cwl" in process["title"]:
            l1b_deployed = True
            break

    assert not l1b_deployed


@given("the proper JSON data for the POST request body")
def proper_json_data_post_request_body(deploy_post_request_body):
    return deploy_post_request_body


@when(
    "a POST request is called on the WPS-T processes endpoint",
    target_fixture="response",
)
def post_processes(process_service_endpoint, deploy_post_request_body):
    url = urljoin(process_service_endpoint, "processes")
    deploy_process_response = requests.post(url, json=deploy_post_request_body)
    deploy_process_response.raise_for_status()
    return deploy_process_response


@then("the HTTP response body contains a DeploymentResult")
def response_contains_deployment_results(response):
    response_json = response.json()
    assert "deploymentResult" in response_json
