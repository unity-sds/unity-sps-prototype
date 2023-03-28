import pytest
from pytest_bdd import scenario, given, when, then
import requests
from urllib.parse import urljoin

from .conftest import FEATURES_DIR

feature_file = "start_prewarm.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@pytest.mark.skip(reason="This feature is currently unsupported")
@scenario(FEATURE_FILE, "Request SPS to start a prewarming of backend resources")
def test_start_prewarm():
    pass


@given("the proper JSON data for the POST request body")
def proper_json_data_post_request_body(start_prewarm_post_request_body):
    return start_prewarm_post_request_body


@when(
    "a POST request is called on the SPS API prewarm endpoint",
    target_fixture="response",
)
def post_processes(sps_api_service_endpoint, start_prewarm_post_request_body):
    url = urljoin(sps_api_service_endpoint, "sps/prewarm")
    start_prewarm_response = requests.post(url, json=start_prewarm_post_request_body)
    start_prewarm_response.raise_for_status()
    return start_prewarm_response
