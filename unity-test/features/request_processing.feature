Feature: Request Processing of an Algorithm Process
    Scenario: Request Processing of a deployed L1B algorithm process
        Given the SoundsSIPS L1B algorithm has been deployed to the ADES
        # And SounderSIPS L1A data exists in the Unity system
        When a WPS-T request is made to execute the L1B job and the defined L1A Data
        Then the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
