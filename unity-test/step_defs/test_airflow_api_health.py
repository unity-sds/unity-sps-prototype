from datetime import datetime, timezone

import backoff
import requests
from pytest_bdd import given, scenario, then, when
from .conftest import FEATURES_DIR

feature_file = "airflow_api_health.feature"
FEATURE_FILE = FEATURES_DIR.joinpath(feature_file)

airflow_components = ["metadatabase", "scheduler", "triggerer", "dag_processor"]


@scenario(FEATURE_FILE, "Check API health")
def test_check_api_health():
    pass


@given("the Airflow API is up and running")
def api_up_and_running():
    pass


@when("I send a GET request to the health endpoint", target_fixture="response")
@backoff.on_exception(
    backoff.constant,
    (AssertionError, requests.exceptions.RequestException),
    max_time=120,
    jitter=None,
    interval=10,
)
def send_get_request(airflow_api_url):
    response = requests.get(f"{airflow_api_url}/health")
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"
    return response


@then("I receive a response with status code 200")
def check_status_code(response):
    assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"


@then("each Airflow component is reported as healthy")
def check_components_health(response):
    data = response.json()
    for c in airflow_components:
        assert data[c]["status"] == "healthy", f"{c} is not healthy"


@then("each Airflow component's last heartbeat was received less than 30 seconds ago")
def check_last_heartbeat(response):
    data = response.json()
    now = datetime.now(timezone.utc)
    for c in airflow_components:
        if c == "metadatabase":
            continue

        last_heartbeat = datetime.strptime(
            data[c]["latest_{}_heartbeat".format(c)],
            "%Y-%m-%dT%H:%M:%S.%f%z",
        )
        assert (now - last_heartbeat).total_seconds() < 30, f"Last {c} heartbeat was more than 30 seconds ago"
