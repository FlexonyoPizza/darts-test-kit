require_relative '../helpers/flow_helpers'
require_relative '../helpers/operation_client'
require_relative 'defaults'
require 'dapl_test_kit/groups/dapl_deidentified_resource_validation_group'

module DartsTestKit
  class ValidatorDeIdentifyValidateRequest < Inferno::Test
    include FlowHelpers
    id :darts_validator_de_identify_validate_request
    title 'Validate the $de-identify request payload'
    description %(
      Reads the US Core data that will be sent to `$de-identify` and checks its structure, collecting
      the input resources for the US Core conformance check that follows. Validating the outbound
      request first confirms that conformant input is being sent, so a later failure can be attributed
      to the Trust Service Provider rather than to bad test data.
    )

    input :de_identify_request,
          title: 'De-Identify Request (US Core)',
          description: 'US Core data to de-identify, as raw JSON or an HTTP(S) URL',
          type: 'textarea',
          optional: true

    run { validate_request(de_identify_request, policy_required: false) }
  end

  class ValidatorDeIdentifyValidateRequestData < Inferno::Test
    include FlowHelpers
    id :darts_validator_de_identify_validate_request_data
    title 'Request data conforms to US Core'
    description 'Validates the collected input resources against US Core profiles.'

    run { validate_request_data(target: :us_core) }
  end

  class ValidatorDeIdentifyInvoke < Inferno::Test
    include FlowHelpers
    include OperationClient
    id :darts_validator_de_identify_invoke
    title 'Invoke $de-identify on the Trust Service Provider and read the response'
    description %(
      Sends the US Core request to the Trust Service Provider's `$de-identify` endpoint
      (`POST [base]/Patient/$de-identify`) and reads the de-identified response, checking its payload
      structure and collecting the returned resources for the DAPL validation group that follows.

      The response payload form is also checked against the request's. The DARTS IG specifies that
      the two must match - a Bundle request is answered with a Bundle, and an NDJSON file-URLs
      request with file URLs - so a response that switches form fails here.
    )

    input :de_identify_request,
          title: 'De-Identify Request (US Core)',
          type: 'textarea',
          optional: true
    input :tsp_base_url,
          title: 'Trust Service Provider Base URL',
          description: 'Base URL of the Trust Service Provider under test. The operation path is appended.',
          optional: true

    run do
      response_body = invoke_operation(
        de_identify_request,
        operation_path: '/Patient/$de-identify',
        base_url: tsp_base_url
      )
      validate_response(response_body, scratch_key: :dapl_resources)
    end
  end

  class ValidatorDeIdentifySubmitGroup < Inferno::TestGroup
    id :darts_validator_de_identify_submit_group
    title 'Submit and Invoke'
    description %(
      Validates the outbound US Core request, then invokes `$de-identify` on the Trust Service
      Provider and reads the response for the DAPL validation that follows.
    )
    run_as_group

    test from: :darts_validator_de_identify_validate_request
    test from: :darts_validator_de_identify_validate_request_data
    test from: :darts_validator_de_identify_invoke
  end

  class ValidatorDeIdentifyGroup < Inferno::TestGroup
    id :darts_validator_de_identify_group
    title 'De-Identify Operation ($de-identify)'
    description %(
      Validates the Trust Service Provider's `$de-identify` operation: checks the outbound US Core
      request, invokes the operation over HTTP, then validates the de-identified response resource by
      resource against the individual DAPL profiles.
    )
    run_as_group

    group from: :darts_validator_de_identify_submit_group
    group from: :dapl_deidentified_resource_validation_group
  end
end
