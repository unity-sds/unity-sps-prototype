Feature: Undeploy an OGC Process
    Scenario Outline: Request a currently deployed algorithm process be undeployed
        Given the <project_name> <process_name> algorithm process has been deployed to the ADES
        When a DELETE request is called on the WPS-T processes endpoint for a given process ID
        Then the HTTP response contains a status code of 200
        And the algorithm is no longer contained in the list of deployed processes

        Examples:
        | project_name | process_name     |
        | sounder_sips |  L1A             |
        | sounder_sips |  L1B             |
        | sounder_sips |  chirp |
