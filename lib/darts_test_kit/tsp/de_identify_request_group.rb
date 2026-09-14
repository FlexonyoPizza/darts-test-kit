require_relative '../helpers/flow_helpers'
require_relative 'de_identify_endpoint' # for the wait identifier and default response payload

module DartsTestKit
  module TSP
    # The TSP side of the $de-identify exchange: wait for the Data Submitter's call, check that what
    # arrived is a well-formed operation request, and return the configured de-identified payload.
    # Conformance of the submitted data is the Data Submitter's responsibility, so it is graded in
    # the DARTS Client Suite before the call is made, not here.
    class DeIdentifyWaitTest < Inferno::Test
      id :darts_tsp_de_identify_wait
      title 'Wait for the $de-identify request'
      description %(
        Pauses until a POST is received at `.../custom/darts_tsp/Patient/$de-identify`. The endpoint
        records the request, resumes this test, and returns the de-identified payload below to the
        caller. No credentials are required: sending to the URL is all that is needed.
      )

      input :de_identify_response,
            title: 'De-Identified Response Payload (DAPL)',
            description: 'The exact JSON this simulated endpoint returns to the caller',
            type: 'textarea',
            optional: true

      run do
        wait(
          identifier: DeIdentifyEndpoint::WAIT_IDENTIFIER,
          message: 'Waiting for a POST to ' \
                   "`#{Inferno::Application['base_url']}/custom/darts_tsp/Patient/$de-identify`. " \
                   'Start the DARTS Client Suite with that base URL to send it.'
        )
      end
    end

    class DeIdentifyValidateInboundRequest < Inferno::Test
      include FlowHelpers
      id :darts_tsp_de_identify_validate_request
      title 'Inbound request is a well-formed operation request'
      description 'Validates the structure of the received $de-identify request and collects its input resources.'

      run do
        load_tagged_requests('de_identify_request')
        skip_if requests.empty?, 'No $de-identify request was received.'
        validate_request(requests.last.request_body, policy_required: false)
      end
    end

    class DeIdentifyRequestGroup < Inferno::TestGroup
      id :darts_tsp_de_identify_request_group
      title 'Receive De-Identify Request'
      description %(
        Receives a `$de-identify` call from a Data Submitter and checks that what arrived is a
        well-formed operation request, then returns the configured de-identified payload as the
        response.

        US Core conformance of the submitted data is not graded here: a Data Submitter is responsible
        for sending conformant data, so the DARTS Client Suite validates it before the call is made.
      )
      run_as_group

      test from: :darts_tsp_de_identify_wait
      test from: :darts_tsp_de_identify_validate_request
    end
  end
end
