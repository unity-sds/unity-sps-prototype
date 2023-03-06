from pytest_bdd import scenario, when, then
import requests
from urllib.parse import urljoin

from .conftest import FEATURES_DIR

feature_file = "get_process_inputs.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "The process is currently deployed and a request is made to get its inputs",
)
def test_get_the_inputs_for_a_given_algorithm_deployment():
    pass


@when(
    "DescribeProcess is called on the WPS-T endpoint for the L1B Algorithm",
    target_fixture="response",
)
def describe_process_l1b_algorithm(process_service_endpoint, project_process_dict):
    url = urljoin(
        process_service_endpoint,
        f'/processes/{project_process_dict["process_name"].casefold()}:develop',
    )
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()
    return get_processes_response


@then("the WPS-T endpoint responds with a ProcessOfferings response")
def response_contains_process_offerings(response):
    pass


@then("the response includes one or more input element")
def response_includes_input_element(response):
    process_json = response.json()

    assert "process" in process_json
    assert "inputs" in process_json["process"]
    assert len(process_json["process"]["inputs"]) >= 1
