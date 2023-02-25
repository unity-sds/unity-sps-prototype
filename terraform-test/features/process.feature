
Feature: Science Processing Service
  The ADES is fronted by a WPS-T service which allows for the deployment and
  undeployment of application packages. It also allows for the exectuion,
  status, and retrieval of job submissions. This is captured in the zenhub epic
  at https://app.zenhub.com/workspaces/unity-workspace-61d4b6a48ed26b001d7d184a/issues/unity-sds/unity-sps-prototype/57

  Scenario: Request Deployment of the L1B algorithm process
    Given the proper JSON data for the POST request body
    When a POST request is called on the WPS-T processes endpoint
    Then the HTTP response contains a status code of 201
    And the HTTP response body contains a DeploymentResult

  Scenario: List deployed WPS Processes
    Given the SoundsSIPS L1B algorithm has been deployed to the ADES
    When a GET request is called on the WPS-T processes endpoint
    Then the HTTP response contains a status code of 200
    And the response includes process summary elements
    And the process summary included the L1B processor

  Scenario: Get the inputs for a given Algorithm deployment
    Given the SoundsSIPS L1B algorithm has been deployed to the ADES
    When DescribeProcess is called on the WPS-T endpoint for the L1B Algorithm
    Then the WPS-T endpoint responds with a ProcessOfferings response
    And the HTTP response contains a status code of 200
    And the response includes one or more input element

  # Scenario: Request L1A Processing from an Algorithm deployment
  #   Given the SoundsSIPS L1A algorithm has been deployed to the ADES
  #   And SounderSIPS L0 data exists for a 2 hour block of Data in the Unity system
  #   When a WPS-T request is made to execute the job and the defined L0 Data
  #   Then a WPS-T response is a 201
  #   And the response includes a Location header
  #   And the Location header directs users to an OGC StatusInfo document
  #   And the OGC StatusInfo document returns a HTTP 200
  #   And the OGC StatusInfo processing status is one of "Succeeded", "Failed", "Accepted", or "Running"

  Scenario: Request L1B Processing from an Algorithm deployment
    Given the SoundsSIPS L1B algorithm has been deployed to the ADES
    # And SounderSIPS L1A data exists in the Unity system
    When a WPS-T request is made to execute the job and the defined L1A Data
    Then the HTTP response contains a status code of 201
    And the response includes a Location header
    And the Location header directs users to an OGC StatusInfo document
    And the OGC StatusInfo document returns a HTTP 200
    And the OGC StatusInfo processing status is one of "Succeeded", "Failed", "Accepted", or "Running"

  # Scenario: Get the result of a process request
  #   Given a job processing id for a processing Request
  #   When a user queries the WPS-T for the given job Id
  #   Then the response returns an HTTP 200
  #   And the OGC StatusInfo processing status is one of "Succeeded", "Failed", "Accepted", or "Running"

  # Scenario: Undeploy an Algorithm deployment
