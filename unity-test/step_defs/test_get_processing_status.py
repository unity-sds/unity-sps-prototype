from pytest_bdd import scenario, given, when, then
import requests
from urllib.parse import urljoin

from .conftest import FEATURES_DIR, _request_job_execution

feature_file = "get_processing_status.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "After requesting execution of the L1B process, job status request is made",
)
def test_after_requesting_execution_of_the_l1b_process_job_status_request_is_made():
    pass


@given(
    "a WPS-T request is made to execute the L1B job and the defined L1A Data",
    target_fixture="response",
)
def request_job_execution(process_service_endpoint, execution_post_request_body):
    job_execution_response = _request_job_execution(
        process_service_endpoint, execution_post_request_body
    )
    return job_execution_response


@given("the HTTP response contains a status code of 201")
def created_response(response):
    assert response.status_code == 201


@given("the response includes a Location header", target_fixture="location_header")
def response_includes_location_header(response):
    assert "Location" in response.headers
    return response.headers["Location"]


@given("the Location header contains a job ID", target_fixture="job_id")
def response_includes_location_header(location_header):
    job_id = location_header.rsplit("/jobs/", 1)[-1]
    assert job_id
    return job_id


@when(
    "a WPS-T request is made to get the status of the job by its ID",
    target_fixture="response",
)
def request_job_status_by_id(process_service_endpoint, job_id):
    url = urljoin(process_service_endpoint, f"/processes/l1b-cwl:develop/jobs/{job_id}")
    job_status_response = requests.get(url)
    job_status_response.raise_for_status()
    return job_status_response


@then('the processing status is one of "succeeded", "failed", "accepted", or "running"')
def acceptable_processing_status(response):
    processing_statuses = ["succeeded", "failed", "accepted", "running"]
    response_json = response.json()
    assert "status" in response_json
    assert response_json["status"] in processing_statuses
