from pytest_bdd import scenario, given, when, then
import backoff
import requests

from .conftest import FEATURES_DIR, _request_job_status_by_id

feature_file = "get_processing_status.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "After requesting execution of a process, a job status request is made",
)
def test_after_requesting_execution_of_process_job_status_request_is_made():
    pass


@given("the HTTP response contains a status code of 201")
def created_response(response):
    assert response.status_code == 201


@when(
    "a WPS-T request is made to get the status of the job by its ID",
    target_fixture="response",
)
@backoff.on_exception(
    backoff.constant,
    (requests.exceptions.HTTPError),
    max_time=3600,
    jitter=None,
    logger=None,
    interval=10,
)
def request_job_status_by_id(process_service_endpoint, project_process_dict, job_id):
    return _request_job_status_by_id(
        process_service_endpoint,
        project_process_dict["process_name"],
        job_id,
    )


@then('the processing status is one of "succeeded", "failed", "accepted", or "running"')
def acceptable_processing_status(response):
    processing_statuses = ["succeeded", "failed", "accepted", "running"]
    response_json = response.json()
    assert "status" in response_json
    assert response_json["status"] in processing_statuses
