from urllib.parse import urljoin

import pytest
import requests
from pytest_bdd import scenario, then, when

from .conftest import FEATURES_DIR

feature_file = "delete_prewarm_request.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@pytest.mark.skip(reason="This feature is currently unsupported")
@scenario(FEATURE_FILE, "Delete an SPS prewarm request")
def test_delete_prewarm_request():
    pass


@when(
    "a DELETE request is called on the SPS API prewarm request endpoint",
    target_fixture="response",
)
def delete_prewarm_request(sps_api_service_endpoint, request_id):
    url = urljoin(sps_api_service_endpoint, f"sps/prewarm/{request_id}")
    delete_prewarm_request_response = requests.delete(url)
    delete_prewarm_request_response.raise_for_status()
    return delete_prewarm_request_response


@then("the prewarm request is deleted")
def verify_deleted_prewarm(request_id):
    return request_id
