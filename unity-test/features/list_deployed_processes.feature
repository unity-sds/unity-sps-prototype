Feature: List deployed OGC Processes
    Scenario Outline: A process is currently deployed and a request is made to list the OGC processes
        Given the <project_name> <process_name> algorithm process has been deployed to the ADES
        When a GET request is called on the WPS-T processes endpoint
        Then the HTTP response contains a status code of 200
        And the response includes process summary elements
        And the process summary included the <process_name> processor

        Examples:
        | project_name | process_name     |
        | sounder_sips |  L1A             |
        | sounder_sips |  L1B             |
        | sounder_sips |  chirp |
