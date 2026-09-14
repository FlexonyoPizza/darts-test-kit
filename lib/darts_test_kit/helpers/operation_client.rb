module DartsTestKit
  # Validator (data-submitter) side of the live round-trip: POST an operation request to the Trust
  # Service Provider's endpoint and return the response body for validation. Pairs with the TSP
  # Suite's SuiteEndpoint, which receives the call and returns the de-identified/anonymized preset.
  module OperationClient
    # POST +request_payload+ (raw JSON) to +base_url+ + +operation_path+ and return the response body.
    # The base URL is the only configuration an operation needs.
    def invoke_operation(request_payload, operation_path:, base_url:)
      assert request_payload.present?, 'No operation request was provided to send to the TSP.'
      assert base_url.present?, 'No Trust Service Provider base URL was provided.'

      url = "#{base_url.chomp('/')}#{operation_path}"
      headers = { 'Content-Type' => 'application/fhir+json', 'Accept' => 'application/fhir+json' }
      headers['Authorization'] = "Bearer #{access_token}" if access_token.present?

      post(url, body: request_payload, headers: headers, name: :darts_operation)
      assert_response_status([200, 201])
      assert request.response_body.present?, 'The TSP returned an empty response body.'
      request.response_body
    end

    # The token produced by the Obtain Access Token group, if it was run. The operation groups
    # deliberately have no bearer token input: a Trust Service Provider that needs authorization is
    # set up once in that group, and one that does not is called with no Authorization header at all.
    def access_token
      @access_token ||=
        Inferno::Repositories::SessionData.new.load(test_session_id: test_session_id, name: :bearer_token)
    end
  end
end
