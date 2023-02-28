Feature: Deploy an OGC Process
  Scenario: Request deployment of the currently undeployed L1B algorithm process
    Given the L1B algorithm process is currently undeployed
    And the proper JSON data for the POST request body
    When a POST request is called on the WPS-T processes endpoint
    Then the HTTP response contains a status code of 201
    And the HTTP response body contains a DeploymentResult
