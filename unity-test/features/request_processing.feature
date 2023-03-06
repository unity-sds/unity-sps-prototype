Feature: Request Processing of an Algorithm Process
    Scenario Outline: Request Processing of a deployed algorithm process
        Given the <project_name> <process_name> algorithm process has been deployed to the ADES
        # And SounderSIPS L1A data exists in the Unity system
        When a WPS-T request is made to execute the process
        Then the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID

        Examples:
        | project_name | process_name |
        | sounder_sips |  L1A   |
        | sounder_sips |  L1B   |
