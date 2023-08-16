from pytest_bdd import scenario, given, when, then, parsers
from elasticsearch import Elasticsearch
import backoff
import requests
from .conftest import FEATURES_DIR, _request_job_status_by_id
from .utils import JsonReader

feature_file = "jobs_database_status.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)


@scenario(
    FEATURE_FILE,
    "Following a job execution request of a deployed algorithm process, the job is added to the jobs database",
)
def test_following_processing_request_job_added_to_jobs_database():
    pass

@scenario(
    FEATURE_FILE,
    "Following a job execution request of a deployed algorithm process that results in a success, the jobs database reflects the success",
)
def test_following_successful_processing_request_job_added_to_job_database_status_is_success():
    pass

@scenario(
    FEATURE_FILE,
    "Following a job execution request of a deployed algorithm process, the jobs database show that the job is running",
)
def test_following_processing_request_job_added_to_jobs_database():
    pass

def fatal_status(e):
    fatal = False
    if isinstance(e, AssertionError):
        if "failed" in e.args[0]:
            fatal = True
    return fatal

@given(
    "the job is running"
)
@backoff.on_exception(
    backoff.constant,
    (AssertionError, requests.exceptions.HTTPError),
    max_time=3600,
    giveup=fatal_status,
    jitter=None,
    interval=0.1, # check more frequently since jobs can execute quickly
)
def request_job_status_by_id_running(process_service_endpoint, project_process_dict, job_id):
    job_status_response = _request_job_status_by_id(
        process_service_endpoint,
        project_process_dict["process_name"],
        job_id,
    )
    response_json = job_status_response.json()
    assert "status" in response_json

    job_status = response_json["status"]
    assert job_status == "running"


@given(
    "the job runs successfully"
)
@backoff.on_exception(
    backoff.constant,
    (AssertionError, requests.exceptions.HTTPError),
    max_time=3600,
    giveup=fatal_status,
    jitter=None,
    interval=1,
)
def request_job_status_by_id_succeeded(process_service_endpoint, project_process_dict, job_id):
    job_status_response = _request_job_status_by_id(
        process_service_endpoint,
        project_process_dict["process_name"],
        job_id,
    )
    response_json = job_status_response.json()
    assert "status" in response_json

    job_status = response_json["status"]
    assert job_status == "succeeded"

@when(
    "the status of the job is queried through the jobs database",
    target_fixture="job_from_database"
)
def request_job_by_id_jobs_database(jobs_database_client, job_id):
    job = jobs_database_client.get(index="jobs", id=job_id)
    return job["_source"]

@then(
    'the job status is "submitted" or "failed"'
)
def job_status_submitted_or_failed(job_from_database):
    assert job_from_database["status"] == "submitted" or job_from_database["status"] == "failed"

@then(
    'the job has the request data in appropriate fields'
)
def job_data_in_appropriate_fields(job_from_database, job_request_body):
    fields = ["id", "status", "inputs", "outputs", "labels"]
    for field in fields:
        assert field in job_from_database
    
    for input in job_request_body["inputs"]:
        assert input["id"] in job_from_database["inputs"]
        assert job_from_database["inputs"][input["id"]] == input["data"]
    
    if "labels" in job_request_body:
        for label in job_request_body["labels"]:
            assert label in job_from_database["labels"]

@then(
    'the job status is "succeeded"'
)
def job_status_submitted_or_failed(job_from_database):
    assert job_from_database["status"] == "succeeded"

@then(
    'the job status is "running"'
)
def job_status_submitted_or_failed(job_from_database):
    assert job_from_database["status"] == "running"