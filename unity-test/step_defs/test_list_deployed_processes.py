from pytest_bdd import scenario, when, then
import requests
from urllib.parse import urljoin
from .conftest import FEATURES_DIR

feature_file = "list_deployed_processes.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "The L1B process is currently deployed and a request is made to list the OGC processes",
)
def test_list_deployed_wps_processes():
    pass


@when(
    "a GET request is called on the WPS-T processes endpoint", target_fixture="response"
)
def get_processes(process_service_endpoint):
    url = urljoin(process_service_endpoint, "processes")
    get_processes_response = requests.get(url)
    return get_processes_response


@then("the response includes process summary elements")
def process_summary_elements(response):
    required_keys = [
        "abstract",
        "executionUnit",
        "id",
        "immediateDeployment",
        "jobControlOptions",
        "keywords",
        "outputTransmission",
        "owsContextURL",
        "processVersion",
        "title",
    ]
    response_json = response.json()
    assert "processes" in response_json
    processes = response_json["processes"]
    for process in processes:
        assert all(key in process for key in required_keys)


@then("the process summary included the L1B processor")
def process_summary_processor(response):
    l1b_processor_present = False
    process_json = response.json()["processes"]
    for process in process_json:
        if "l1b-cwl" in process["id"]:
            if l1b_processor_present:
                raise ValueError("Duplicate process title")
            else:
                l1b_processor_present = True
    assert l1b_processor_present
