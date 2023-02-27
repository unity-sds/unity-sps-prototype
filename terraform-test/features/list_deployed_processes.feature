Feature: List deployed OGC Processes
    Scenario: The L1B process is currently deployed and a request is made to list the OGC processes
        Given the SoundsSIPS L1B algorithm has been deployed to the ADES
        When a GET request is called on the WPS-T processes endpoint
        Then the HTTP response contains a status code of 200
        And the response includes process summary elements
        And the process summary included the L1B processor
