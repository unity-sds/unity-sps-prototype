from pytest_bdd import scenario, given, when, then
from pathlib import Path
import requests

feature_file_dir = "features"
feature_file = "process.feature"
BASE_DIR = Path(__file__).resolve().parents[1]
FEATURE_FILE = BASE_DIR.joinpath(feature_file_dir).joinpath(feature_file)

# @scenario(FEATURE_FILE, 'Request Deployment of the L1B algorithm process')
# def test_request_deployment_of_the_l1b_algorithm_process():
#     pass

@scenario(FEATURE_FILE, "List deployed WPS Processes")
def test_list_deployed_wps_processes():
    pass

# @scenario(FEATURE_FILE, 'Get the inputs for a given Algorithm deployment')
# def test_get_the_inputs_for_a_given_algorithm_deployment():
#     pass

# @scenario(FEATURE_FILE, 'Request L1B Processing from an Algorithm deployment')
# def test_request_l1b_processing_from_an_algorithm_deployment():
#     pass


@given("the SoundsSIPS L1B algorithm has been deployed to the ADES")
def l1b_deployed(process_service_endpoint):
    json_data = {
        "processDescription":{
            "process":{
                "id":"l1b-cwl",
                "title":"l1b_pge_cwl",
                "owsContext":{
                    "offering":{
                    "code":"http://www.opengis.net/eoc/applicationContext/cwl",
                    "content":{
                        "href":"https://raw.githubusercontent.com/unity-sds/unity-sps-workflows/main/sounder_sips/ssips_L1b_workflow.cwl"
                    }
                    }
                },
                "abstract":"l1b_pge_cwl",
                "keywords":[
                ],
                "inputs":[
                    {
                    "id":"input_collection_id",
                    "title":"input_collection_id",
                    "formats":[
                        {
                            "mimeType":"text",
                            "default":True
                        }
                    ]
                    },
                    {
                    "id":"start_datetime",
                    "title":"start_datetime",
                    "formats":[
                        {
                            "mimeType":"text",
                            "default":True
                        }
                    ]
                    },
                    {
                    "id":"stop_datetime",
                    "title":"stop_datetime",
                    "formats":[
                        {
                            "mimeType":"text",
                            "default":True
                        }
                    ]
                    },
                    {
                        "id": "output_collection_id",
                        "title": "output_collection_id",
                        "formats":[
                        {
                            "mimeType":"text",
                            "default":True
                        }
                    ]
                    }
                ],
                "outputs":[
                    {
                    "id":"output",
                    "title":"L1B-product",
                    "formats":[
                        {
                            "mimeType":"image/tiff",
                            "default":True
                        }
                    ]
                    }
                ]
            },
            "processVersion":"develop",
            "jobControlOptions":[
                "async-execute"
            ],
            "outputTransmission":[
                "reference"
            ]
        },
        "immediateDeployment":True,
        "executionUnit":[
            {
                "href":"docker.registry/ndvims:latest"
            }
        ],
        "deploymentProfileName":"http://www.opengis.net/profiles/eoc/dockerizedApplication"
    }

    url = process_service_endpoint + "processes"
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()

    response_json = get_processes_response.json()
    assert "processes" in response_json
    processes = response_json["processes"]

    l1b_deployed = False
    for process in processes:
        if "l1b_pge_cwl" in process["title"]:
            l1b_deployed = True
            break

    if not l1b_deployed:
        deploy_process_response = requests.post(url, json=json_data)
        deploy_process_response.raise_for_status()
        l1b_deployed = True

    assert l1b_deployed

@when("a GET request is called on the WPS-T processes endpoint", target_fixture="get_processes_response")
def get_processes(process_service_endpoint):
    url = process_service_endpoint + "processes"
    get_processes_response = requests.get(url)
    return get_processes_response


@then("the HTTP response contains a status code of 200")
def ok_response(get_processes_response):
    assert get_processes_response.status_code == 200


@then("the response includes process summary elements")
def process_summary_elements(get_processes_response):
    required_keys = ['abstract', 'executionUnit', 'id', 'immediateDeployment', 'jobControlOptions', 'keywords', 'outputTransmission', 'owsContextURL', 'processVersion', 'title']
    response_json = get_processes_response.json()
    assert "processes" in response_json
    processes = response_json["processes"]
    for process in processes:
        assert all(key in process for key in required_keys)


@then("the process summary included the L1B processor")
def process_summary_processor(get_processes_response):
    l1b_processor_present = False
    process_json = get_processes_response.json()["processes"]
    for process in process_json:
        if "l1b_pge_cwl" in process["title"]:
            if l1b_processor_present:
                raise ValueError("Duplicate process title")
            else:
                l1b_processor_present = True
    assert l1b_processor_present


@when('DescribeProcess is called on the WPS-T endpoint for the L1B Algorithm', target_fixture="get_processes_response")
def describe_process_l1b_algorithm(process_service_endpoint):
    url = process_service_endpoint + "/processes/l1b-cwl:develop"
    get_processes_response = requests.get(url)
    get_processes_response.raise_for_status()
    return get_processes_response


@then('the WPS-T endpoint responds with a ProcessOfferings response')
def response_contains_process_offerings(get_processes_response):
    pass


@then('the response includes one or more input element')
def response_includes_input_element(get_processes_response):
    process_json = get_processes_response.json()
    assert "process" in process_json
    assert "inputs" in process_json["process"]
    assert len(process_json["process"]["inputs"]) >= 1


@given('the proper JSON data for the POST request body')
def _():
    assert True


@when('DescribeProcess is called on the WPS-T endpoint for the L1B Algorithm')
def _():
    assert True


@when('a POST request is called on the WPS-T processes endpoint')
def _():
    assert True


@when('a WPS-T request is made to execute the job and the defined L1A Data')
def _():
    assert True


@then('the HTTP response body contains a DeploymentResult')
def _():
    assert True


@then('the HTTP response contains a status code of 201')
def _():
    assert True


@then('the Location header directs users to an OGC StatusInfo document')
def _():
    assert True


@then('the OGC StatusInfo document returns a HTTP 200')
def _():
    assert True


@then('the OGC StatusInfo processing status is one of "Succeeded", "Failed", "Accepted", or "Running"')
def _():
    assert True


@then('the WPS-T endpoint responds with a ProcessOfferings response')
def _():
    assert True


@then('the response includes a Location header')
def _():
    assert True


@then('the response includes one or more input element')
def _():
    assert True
