Feature: Get SPS Prewarm Request Status
    Scenario: Request the status of an SPS prewarm request
        Given the prewarm request has been created
        When a GET request is called on the SPS API prewarm request endpoint
        Then the HTTP response contains a successful status code
        And the HTTP response body contains a request id
