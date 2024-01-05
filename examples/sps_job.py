"""
Example script that exercises SPS functionality related to Jobs.
The authentication credentials can be read from the environment variables:
UNITY_USER
UNITY_PASSWORD
or can be injected interactively from the command line.
"""

import requests
import time

from datetime import datetime

from unity_sds_client.unity import Unity
from unity_sds_client.unity_services import UnityServices
from unity_sds_client.resources.job_status import JobStatus

VENUE_ID = "unity-sips-test"
PROCESS_ID = "chirp:develop"

data = {
  "mode": "async",
  "response": "document",
  "inputs": [
    {
      "id": "input_processing_labels",
      "data": [
        "gangl_test"
      ]
    },
    {
      "id": "input_cmr_collection_name",
      "data": "C2011289787-GES_DISC"
    },
    {
      "id": "input_cmr_search_start_time",
      "data": "2016-08-30T00:10:00Z"
    },
    {
      "id": "input_cmr_search_stop_time",
      "data": "2016-08-31T01:10:00Z"
    },
    {
      "id": "input_cmr_edl_user",
      "data": "cmr_user"
    },
    {
      "id": "input_cmr_edl_pass",
      "data": "cmr_pass"
    },
    {
      "id": "output_collection_id",
      "data": "urn:nasa:unity:ssips:TEST1:CHRP_16_DAY_REBIN___1"
    },
    {
      "id": "output_data_bucket",
      "data": " ssips-test-ds-storage-reproc"
    }, {
      "id": "input_daac_collection_shortname",
      "data": "CHIRP_L1B"
    },
    {
      "id": "input_daac_collection_sns",
      "data": "arn:://SNS-arn"
    }
  ],
  "outputs": [
    {
      "id": "output",
      "transmissionMode": "reference"
    }
  ]
}

unity = Unity()
unity.set_venue_id(VENUE_ID)
process_service = unity.client(UnityServices.PROCESS_SERVICE)

# Submit a job for the given process
process = process_service.get_process(PROCESS_ID)
try:
    job = process.execute(data)
    print(job)
    # If the job submission is successful, print a success message along with the returned JOB-ID
    print("\nJob Submission Successful!\nJOB ID: {}\n".format(job.id))

    # Monitor the job until completion
    job_status = job.get_status()
    while job_status == JobStatus.RUNNING:
        print("Status for job \"{}\" ({}): {}".format(job.id,
                                                      datetime.now().strftime("%H:%M:%S"), job_status.value))
        time.sleep(5)
        job_status = job.get_status()
        print("\nStatus for job \"{}\" ({}): {}\n".format(job.id,
                                                          datetime.now().strftime("%H:%M:%S"), job_status.value))

    # Print the final status
    print("\nFinal status for job \"{}\" ({}): {}\n".format(job.id,
                                                            datetime.now().strftime("%H:%M:%S"), job_status.value))


except requests.exceptions.HTTPError as e:
    # An error has occurred, print the error message that was generated
    print(e)
