require_relative '../helpers/flow_helpers'
require_relative 'pseudonymize_endpoint' # for the wait identifier and default response payload

module DartsTestKit
  module TSP
    # The TSP side of the $pseudonymize exchange: wait for the Data Submitter's call, check that what
    # arrived is a well-formed operation request, and return the configured pseudonymized payload.
    # Conformance of the submitted data is graded in the DARTS Client Suite before the call is made.
    class PseudonymizeWaitTest < Inferno::Test
      id :darts_tsp_pseudonymize_wait
      title 'Wait for the $pseudonymize request'
      description %(
        Pauses until a POST is received at `.../custom/darts_tsp/Patient/$pseudonymize`. The endpoint
        records the request, resumes this test, and returns the pseudonymized payload below to the
        caller. No credentials are required: sending to the URL is all that is needed.
      )

      input :pseudonymize_response,
            title: 'Pseudonymized Response Payload (US Core)',
            description: 'The exact JSON this simulated endpoint returns to the caller',
            type: 'textarea',
            optional: true

      run do
        wait(
          identifier: PseudonymizeEndpoint::WAIT_IDENTIFIER,
          message: 'Waiting for a POST to ' \
                   "`#{Inferno::Application['base_url']}/custom/darts_tsp/Patient/$pseudonymize`. " \
                   'Start the DARTS Client Suite with that base URL to send it.'
        )
      end
    end

    class PseudonymizeValidateInboundRequest < Inferno::Test
      include FlowHelpers
      id :darts_tsp_pseudonymize_validate_request
      title 'Inbound request is a well-formed operation request'
      description 'Validates the structure of the received $pseudonymize request and collects its input resources.'

      run do
        load_tagged_requests('pseudonymize_request')
        skip_if requests.empty?, 'No $pseudonymize request was received.'
        validate_request(requests.last.request_body, policy_required: false)
      end
    end

    class PseudonymizeRequestGroup < Inferno::TestGroup
      id :darts_tsp_pseudonymize_request_group
      title 'Receive Pseudonymize Request'
      description %(
        Receives a `$pseudonymize` call from a Data Submitter and checks that what arrived is a
        well-formed operation request, then returns the configured pseudonymized **US Core** payload as
        the response (pseudonymized data remains PHI).

        US Core conformance of the submitted data is not graded here: a Data Submitter is responsible
        for sending conformant data, so the DARTS Client Suite validates it before the call is made.
      )
      run_as_group

      test from: :darts_tsp_pseudonymize_wait
      test from: :darts_tsp_pseudonymize_validate_request
    end
  end
end
