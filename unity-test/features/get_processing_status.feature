Feature: Get the processing status of a job
    Scenario: After requesting execution of the L1B process, job status request is made
        Given the SoundsSIPS L1B algorithm has been deployed to the ADES
        And a WPS-T request is made to execute the L1B job and the defined L1A Data
        And the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
        When a WPS-T request is made to get the status of the job by its ID
        Then the HTTP response contains a status code of 200
        # And the response contains an OGC StatusInfo document
        And the processing status is one of "succeeded", "failed", "accepted", or "running"
