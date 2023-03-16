Feature: The Processes Execute Successfully
    Scenario Outline: Following a processing request of a deployed algorithm process, the job executes successfully to completion
        Given the <project_name> <process_name> algorithm process has been deployed to the ADES
        And a WPS-T request is made to execute the process
        And the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
        When the status of the job is monitored through the WPS-T
        Then the processing status ultimately ends in the "succeeded" state

        Examples:
        | project_name | process_name     |
        | sounder_sips |  L1A             |
        | sounder_sips |  L1B             |
        | sounder_sips |  chirp |
