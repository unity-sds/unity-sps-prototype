from pytest_bdd import scenario, when, then
import requests
from urllib.parse import urljoin
from .conftest import FEATURES_DIR

feature_file = "undeploy_process.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE, "Request a currently deployed L1B algorithm process be undeployed"
)
def test_request_undeployment_of_the_l1b_algorithm_process():
    pass


@when(
    "a DELETE request is called on the WPS-T processes endpoint for a given process ID",
    target_fixture="response",
)
def delete_request_process_id(process_service_endpoint):
    url = urljoin(process_service_endpoint, "/processes/l1b-cwl:develop")
    undeploy_process_response = requests.delete(url)
    undeploy_process_response.raise_for_status()
    return undeploy_process_response


@then(
    "the the SoundsSIPS L1B algorithm is no longer contained in the list of deployed processes"
)
def l1b_process_no_longer_deployed(process_service_endpoint):
    url = urljoin(process_service_endpoint, "processes")
    response = requests.get(url)

    l1b_process_deployed = False
    process_json = response.json()["processes"]
    for process in process_json:
        if "l1b_pge_cwl" in process["title"]:
            l1b_process_deployed = True
            break
    assert not l1b_process_deployed
