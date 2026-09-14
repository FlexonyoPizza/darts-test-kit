require 'inferno/dsl/suite_endpoint'

module DartsTestKit
  module TSP
    # Shared behavior for the three simulated DARTS operation endpoints. Each receives an incoming
    # POST, matches it to the "receive" test waiting for it, records the inbound request for the
    # validation tests that follow, resumes that test run, and returns the response payload configured
    # for the session.
    #
    # Subclasses set four constants:
    #   WAIT_IDENTIFIER       - matches an incoming POST to the test waiting on this operation. The
    #                           operation's own URL is the only coordination needed, so no credential
    #                           has to be entered on both sides to complete the exchange.
    #   DEFAULT_RESPONSE_BODY - the JSON string returned when the response payload input is left blank
    #   RESPONSE_INPUT        - name of the input holding the response payload to return
    #   REQUEST_TAG           - the tag applied to the recorded request, so the matching request group
    #                           can load it via `load_tagged_requests`
    class OperationEndpoint < Inferno::DSL::SuiteEndpoint
      RESPONSES_DIR = File.join(__dir__, 'responses').freeze

      # @private Read a fixture from tsp/responses.
      def self.response_fixture(filename)
        File.read(File.join(RESPONSES_DIR, filename)).freeze
      end

      # Match the incoming request to the test waiting on this operation. Each operation has its own
      # identifier, so a call to one endpoint never resumes a run waiting on another.
      def test_run_identifier
        self.class::WAIT_IDENTIFIER
      end

      # Tag the recorded request so the operation's request group can load and validate it.
      def tags
        [self.class::REQUEST_TAG]
      end

      # Mark the waiting "receive" test as passed (the request arrived) - this resumes the run.
      def update_result
        results_repo.update(result.id, result: 'pass')
      end

      # The payload to return: whatever was entered into this session's response payload input,
      # falling back to the bundled example when that input is left blank.
      def configured_response_body
        Inferno::Repositories::SessionData.new.load(
          test_session_id: test_run.test_session_id,
          name: self.class::RESPONSE_INPUT
        ).presence || self.class::DEFAULT_RESPONSE_BODY
      end

      # Return the configured operation output.
      def make_response
        response.status = 200
        response.body = configured_response_body
        response.format = :json
      end
    end
  end
end
