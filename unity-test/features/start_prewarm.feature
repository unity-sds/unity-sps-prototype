Feature: Start SPS Prewarming
    Scenario: Request SPS to start a prewarming of backend resources
        Given the proper JSON data for the POST request body
        When a POST request is called on the SPS API prewarm endpoint
        Then the HTTP response contains a successful status code
        And the HTTP response body contains a request id
