import pytest
from . import TEST_BASE_DIR
from dotenv import load_dotenv
from requests.auth import HTTPBasicAuth
import os

# Load environment variables from .env file
load_dotenv()


FEATURES_DIR = TEST_BASE_DIR.joinpath("features")


def pytest_addoption(parser):
    parser.addoption(
        "--project",
        action="store",
        default="unity",
        help="The project or mission deploying the processing system.",
    )
    parser.addoption(
        "--subsystem",
        action="store",
        default="sps",
        help="The service area/subsystem owner of the resources being deployed.",
    )
    parser.addoption(
        "--venue",
        action="store",
        default=None,
        choices=("dev", "int", "ops"),
        help="The venue in which the cluster will be deployed (dev, int, ops).",
    )
    parser.addoption(
        "--counter",
        action="store",
        default=None,
        help="Identifier used to uniquely distinguish resources. This is used in the naming convention of the resources.",
    )
    parser.addoption(
        "--airflow-endpoint",
        action="store",
        help="Base URL for the Airflow service endpoint",
        required=True,
    )


@pytest.fixture(scope="session")
def resource_name_template(request):
    project = request.config.getoption("--project")
    venue = request.config.getoption("--venue")
    subsystem = request.config.getoption("--subsystem")
    counter = request.config.getoption("--counter")

    # Compact: filter out None or empty strings
    components = [project, venue, subsystem, "{}", counter]
    compacted_elements = [element for element in components if element]
    return "-".join(compacted_elements)


@pytest.fixture(scope="session")
def pipeline_namespace():
    ns = "airflow"
    return ns


@pytest.fixture(scope="session")
def airflow_api_url(request):
    url = request.config.getoption("--airflow-endpoint")
    return url


@pytest.fixture(scope="session")
def aws_credentials():
    return {
        "access_key": os.getenv("AWS_ACCESS_KEY_ID"),
        "secret_key": os.getenv("AWS_SECRET_ACCESS_KEY"),
        "region": os.getenv("AWS_DEFAULT_REGION"),
        "localstack_endpoint": os.getenv("LOCALSTACK_ENDPOINT"),
    }


@pytest.fixture(scope="session")
def airflow_api_auth():
    return HTTPBasicAuth("admin", os.getenv("AIRFLOW_WEBSERVER_PASSWORD"))
