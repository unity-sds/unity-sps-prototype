from pytest_bdd import scenario, when, then, parsers
import requests
from urllib.parse import urljoin
from .conftest import FEATURES_DIR, _is_process_deployed

feature_file = "undeploy_process.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(FEATURE_FILE, "Request a currently deployed algorithm process be undeployed")
def test_request_undeployment_of_algorithm_process():
    pass


@when(
    "a DELETE request is called on the WPS-T processes endpoint for a given process ID",
    target_fixture="response",
)
def delete_request_process_id(process_service_endpoint, project_process_dict):
    process_name = project_process_dict["process_name"]
    url = urljoin(
        process_service_endpoint,
        f"/processes/{process_name.casefold()}:develop",
    )
    undeploy_process_response = requests.delete(url)
    undeploy_process_response.raise_for_status()
    return undeploy_process_response


@then(
    parsers.parse(
        "the algorithm is no longer contained in the list of deployed processes"
    )
)
def process_no_longer_deployed(process_service_endpoint, project_process_dict):
    deployed = _is_process_deployed(
        process_service_endpoint, project_process_dict["process_name"]
    )
    assert not deployed
