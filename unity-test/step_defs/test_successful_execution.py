from pytest_bdd import scenario, given, when, then
import backoff

from .conftest import FEATURES_DIR, _request_job_execution, _request_job_status_by_id

feature_file = "successful_execution.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "Following a processing request of the deployed L1B algorithm process, the job executes successfully to completion",
)
def test_following_a_processing_request_of_the_deployed_l1b_algorithm_process_the_job_executes_successfully_to_completion():
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


@when("the job status is monitored through the WPS-T", target_fixture="job_status")
@backoff.on_exception(backoff.expo, AssertionError, max_time=600)
def request_job_status_by_id(process_service_endpoint, job_id):
    job_status_response = _request_job_status_by_id(process_service_endpoint, job_id)
    response_json = job_status_response.json()
    assert "status" in response_json

    job_status = response_json["status"]
    assert job_status == "succeeded"
    return job_status


@then('the processing status ultimately ends in the "succeeded" state')
def acceptable_processing_status(job_status):
    assert job_status == "succeeded"
