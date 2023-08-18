Feature: The Jobs Database has Job Status
    Scenario Outline: Following a job execution request of a deployed algorithm process, the job is added to the jobs database
        Given the <project_name> <process_name> algorithm process has been deployed to the ADES
        And a WPS-T request is made to execute the process
        And the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
        When the status of the job is queried through the jobs database
        Then the job status is "submitted" or "failed"
        And the job has the request data in appropriate fields

        Examples:
        | project_name | process_name     |
        | sounder_sips |  L1A             |
        | sounder_sips |  L1B             |
        | sounder_sips |  chirp         |

    Scenario Outline: Following a job execution request of a deployed algorithm process that results in a success, the jobs database reflects the success
        Given the sounder_sips chirp algorithm process has been deployed to the ADES
        And a WPS-T request is made to execute the process
        And the HTTP response contains a status code of 201
        And the response includes a Location header
        And the Location header contains a job ID
        And the job runs successfully
        When the status of the job is queried through the jobs database
        Then the job status is "succeeded"