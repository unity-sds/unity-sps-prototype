from pytest_bdd import scenario, when, then, parsers
from .conftest import FEATURES_DIR, _request_job_execution, reader

feature_file = "request_processing.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(FEATURE_FILE, "Request Processing of a deployed algorithm process")
def test_request_processing_of_a_deployed_algorithm_process():
    pass


@when(
    parsers.parse("a WPS-T request is made to execute the process"),
    target_fixture="response",
)
def request_job_execution(process_service_endpoint, project_process_dict):
    request_body = reader.request_body(
        project_process_dict["project_name"],
        project_process_dict["process_name"],
        reader.execution_post_request_body,
    )
    job_execution_response = _request_job_execution(
        process_service_endpoint, project_process_dict["process_name"], request_body
    )
    return job_execution_response


@then("the response includes a Location header", target_fixture="location_header")
def response_includes_location_header(response):
    assert "Location" in response.headers
    return response.headers["Location"]


@then("the Location header contains a job ID")
def location_header_contains_job_id(location_header):
    job_id = location_header.rsplit("/jobs/", 1)[-1]
    assert job_id
