"""
Example script that exercises SPS functionality related to Processes.
The authentication credentials can be read from the environment variables:
UNITY_USER
UNITY_PASSWORD
or can be injected interactively from the command line.
"""
from unity_sds_client.unity import Unity
from unity_sds_client.unity_services import UnityServices

VENUE_ID = "unity-sips-test"
PROCESS_ID = "chirp:develop"

unity = Unity()
unity.set_venue_id(VENUE_ID)
process_service = unity.client(UnityServices.PROCESS_SERVICE)
print("WPS-T endpoint=%s" % process_service.endpoint)

# List all deployed processes
processes = process_service.get_processes()
for process in processes:
    print("Process ID: {}".format(process.id))
    print("Process Title: {}".format(process.title))
    print("Process Abstract: {}".format(process.abstract))
    print("Process Version: {}".format(process.process_version))
    print("")
    print(process)

# Query for a specific process
process = process_service.get_process(PROCESS_ID)
print(process)
