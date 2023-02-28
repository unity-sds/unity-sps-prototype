Feature: Undeploy an OGC Process
    Scenario: Request a currently deployed L1B algorithm process be undeployed
        Given the SoundsSIPS L1B algorithm has been deployed to the ADES
        When a DELETE request is called on the WPS-T processes endpoint for a given process ID
        Then the HTTP response contains a status code of 200
        And the the SoundsSIPS L1B algorithm is no longer contained in the list of deployed processes
