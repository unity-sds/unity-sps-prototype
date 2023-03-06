from pytest_bdd import scenario, given, when, then, parsers
import backoff
import json
from .conftest import FEATURES_DIR, _request_job_status_by_id

feature_file = "successful_execution.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "Following a processing request of a deployed algorithm process, the job executes successfully to completion",
)
def test_following_processing_request_job_executes_successfully():
    pass


@given("the HTTP response contains a status code of 201")
def created_response(response):
    assert response.status_code == 201


def fatal_status(e):
    fatal = False
    if isinstance(e, AssertionError):
        if "failed" in e.args[0]:
            fatal = True
    return fatal


@when(
    parsers.parse("the status of the job is monitored through the WPS-T"),
    target_fixture="job_status",
)
@backoff.on_exception(backoff.expo, AssertionError, max_time=600, giveup=fatal_status)
def request_job_status_by_id(process_service_endpoint, project_process_dict, job_id):
    job_status_response = _request_job_status_by_id(
        process_service_endpoint,
        project_process_dict["process_name"],
        job_id,
    )
    response_json = job_status_response.json()
    assert "status" in response_json

    job_status = response_json["status"]
    assert job_status == "succeeded"
    return job_status


@then('the processing status ultimately ends in the "succeeded" state')
def acceptable_processing_status(job_status):
    assert job_status == "succeeded"
