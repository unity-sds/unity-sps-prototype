from urllib.parse import urljoin

import pytest
import requests
from pytest_bdd import scenario, when

from .conftest import FEATURES_DIR

feature_file = "get_prewarm_request_status.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@pytest.mark.skip(reason="This feature is currently unsupported")
@scenario(FEATURE_FILE, "Request the status of an SPS prewarm request")
def test_get_prewarm_status_request():
    pass


@when(
    "a GET request is called on the SPS API prewarm request endpoint",
    target_fixture="response",
)
def get_prewarm_request_status(sps_api_service_endpoint, prewarm_request_id):
    url = urljoin(sps_api_service_endpoint, f"sps/prewarm/{prewarm_request_id}")
    get_prewarm_status_response = requests.get(url)
    get_prewarm_status_response.raise_for_status()
    return get_prewarm_status_response
