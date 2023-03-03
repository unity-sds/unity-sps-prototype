from pytest_bdd import scenario, given, when, then
import requests
from urllib.parse import urljoin

from .conftest import FEATURES_DIR

feature_file = "get_prewarm_request_status.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE, "Request the status of an SPS prewarm request"
)
def test_get_prewarm_status_request():
    pass

@when(
    "a GET request is called on the SPS API prewarm request endpoint",
    target_fixture="response",
)
def get_prewarm_request_status(sps_api_service_endpoint, request_id):
    url = urljoin(sps_api_service_endpoint, f"sps/prewarm/{request_id}")
    get_prewarm_status_response = requests.get(url)
    get_prewarm_status_response.raise_for_status()
    return get_prewarm_status_response