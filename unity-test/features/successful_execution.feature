Feature: The L1B Process Executes Successfully
    Scenario: Following a processing request of the deployed L1B algorithm process, the job executes successfully to completion
        Given the SoundsSIPS L1B algorithm has been deployed to the ADES
        And a WPS-T request is made to execute the L1B job and the defined L1A Data
        And the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
        When the job status is monitored through the WPS-T
        Then the processing status ultimately ends in the "succeeded" state
