
Feature: Deploy an OGC Process
    Scenario Outline: Request deployment of a currently undeployed algorithm process
        Given the <project_name> <process_name> algorithm process is currently undeployed
        And the proper JSON data for the POST request body
        When a POST request is called on the WPS-T processes endpoint
        Then the HTTP response contains a status code of 201
        And the HTTP response body contains a DeploymentResult

        Examples:
        | project_name | process_name     |
        | sounder_sips |  L1A             |
        | sounder_sips |  L1B             |
        | sounder_sips |  chirp |
