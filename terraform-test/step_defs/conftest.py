import pytest
import os
# from unity_py.unity import Unity
# from unity_py.unity_services import UnityServices


# @pytest.fixture
# def unity():
#     unity = Unity()
#     return unity

# @pytest.fixture
# def process_service(unity):
#     process_service = unity.client(UnityServices.PROCESS_SERVICE)
#     return process_service

# @pytest.fixture
# def process_service_endpoint():
#     endpoint = os.environ["PROCESS_SERVICE_ENDPOINT"]
#     return endpoint

def pytest_addoption(parser):
    parser.addoption(
        '--process-service-endpoint', action='store', help='Base URL for the Process service endpoint'
    )


@pytest.fixture
def process_service_endpoint(request):
    return request.config.getoption('--process-service-endpoint')
