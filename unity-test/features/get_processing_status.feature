Feature: Get the processing status of a job
    Scenario Outline: After requesting execution of a process, a job status request is made
        Given the <project_name> <process_name> algorithm process has been deployed to the ADES
        And a WPS-T request is made to execute the process
        And the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
        When a WPS-T request is made to get the status of the job by its ID
        Then the HTTP response contains a status code of 200
        # And the response contains an OGC StatusInfo document
        And the processing status is one of "succeeded", "failed", "accepted", or "running"

        Examples:
        | project_name | process_name     |
        | sounder_sips |  L1A             |
        | sounder_sips |  L1B             |
        | sounder_sips |  chirp |
