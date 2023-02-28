from pytest_bdd import scenario, when, then
from .conftest import FEATURES_DIR, _request_job_execution

feature_file = "request_processing.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(FEATURE_FILE, "Request Processing of a deployed L1B algorithm process")
def test_request_processing_of_the_a_deployed_l1b_algorithm_process():
    pass


@when(
    "a WPS-T request is made to execute the L1B job and the defined L1A Data",
    target_fixture="response",
)
def request_job_execution(process_service_endpoint, execution_post_request_body):
    job_execution_response = _request_job_execution(
        process_service_endpoint, execution_post_request_body
    )
    return job_execution_response


@then("the response includes a Location header", target_fixture="location_header")
def response_includes_location_header(response):
    assert "Location" in response.headers
    return response.headers["Location"]


@then("the Location header contains a job ID")
def response_includes_location_header(location_header):
    job_id = location_header.rsplit("/jobs/", 1)[-1]
    assert job_id
