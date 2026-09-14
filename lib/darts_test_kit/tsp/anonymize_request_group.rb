require_relative '../helpers/flow_helpers'
require_relative 'anonymize_endpoint' # for the wait identifier and default response payload

module DartsTestKit
  module TSP
    # The TSP side of the $anonymize exchange: wait for the Data Submitter's call, check that what
    # arrived is a well-formed operation request, and return the configured anonymized payload.
    # Conformance of the submitted data is graded in the DARTS Client Suite before the call is made.
    class AnonymizeWaitTest < Inferno::Test
      id :darts_tsp_anonymize_wait
      title 'Wait for the $anonymize request'
      description %(
        Pauses until a POST is received at `.../custom/darts_tsp/Patient/$anonymize`. The endpoint
        records the request, resumes this test, and returns the anonymized payload below to the caller.
        No credentials are required: sending to the URL is all that is needed.
      )

      input :anonymize_response,
            title: 'Anonymized Response Payload (DAPL)',
            description: 'The exact JSON this simulated endpoint returns to the caller',
            type: 'textarea',
            optional: true

      run do
        wait(
          identifier: AnonymizeEndpoint::WAIT_IDENTIFIER,
          message: 'Waiting for a POST to ' \
                   "`#{Inferno::Application['base_url']}/custom/darts_tsp/Patient/$anonymize`. " \
                   'Start the DARTS Client Suite with that base URL to send it.'
        )
      end
    end

    class AnonymizeValidateInboundRequest < Inferno::Test
      include FlowHelpers
      id :darts_tsp_anonymize_validate_request
      title 'Inbound request is a well-formed operation request'
      description 'Validates the structure of the received $anonymize request and collects its input resources.'

      run do
        load_tagged_requests('anonymize_request')
        skip_if requests.empty?, 'No $anonymize request was received.'
        validate_request(requests.last.request_body, policy_required: false)
      end
    end

    class AnonymizeRequestGroup < Inferno::TestGroup
      id :darts_tsp_anonymize_request_group
      title 'Receive Anonymize Request'
      description %(
        Receives an `$anonymize` call from a Data Submitter and checks that what arrived is a
        well-formed operation request, then returns the configured anonymized payload as the response.

        US Core conformance of the submitted data is not graded here: a Data Submitter is responsible
        for sending conformant data, so the DARTS Client Suite validates it before the call is made.
      )
      run_as_group

      test from: :darts_tsp_anonymize_wait
      test from: :darts_tsp_anonymize_validate_request
    end
  end
end
