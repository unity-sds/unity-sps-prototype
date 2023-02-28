Feature: Get the inputs for an OGC process
    Scenario: The L1B process is currently deployed and a request is made to get its inputs
        Given the SoundsSIPS L1B algorithm has been deployed to the ADES
        When DescribeProcess is called on the WPS-T endpoint for the L1B Algorithm
        Then the WPS-T endpoint responds with a ProcessOfferings response
        And the HTTP response contains a status code of 200
        And the response includes one or more input element
