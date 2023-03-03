from pytest_bdd import scenario, when, then
import requests
from urllib.parse import urljoin

from .conftest import FEATURES_DIR

feature_file = "get_prewarm_request_status.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE, "Request the status of an SPS prewarm request"
)

@when(
    "a DELETE request is called on the SPS API prewarm request endpoint",
    target_fixture="response",
)
def delete_prewarm_request(prewarm_service_endpoint, request_id):
    url = urljoin(prewarm_service_endpoint, f"sps/prewarm/{request_id}")
    delete_prewarm_request_response = requests.delete(url)
    delete_prewarm_request_response.raise_for_status()
    return delete_prewarm_request_response

@then(
    "the prewarm request is deleted"
)
def verify_deleted_prewarm(request_id):
    return request_id