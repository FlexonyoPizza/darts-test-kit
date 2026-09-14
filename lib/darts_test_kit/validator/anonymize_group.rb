require_relative '../helpers/flow_helpers'
require_relative '../helpers/operation_client'
require_relative 'defaults'
require 'dapl_test_kit/groups/dapl_anonymized_dataset_validation_group'

module DartsTestKit
  class ValidatorAnonymizeValidateRequest < Inferno::Test
    include FlowHelpers
    id :darts_validator_anonymize_validate_request
    title 'Validate the $anonymize request payload'
    description %(
      Reads the US Core population data that will be sent to `$anonymize` and checks its structure,
      collecting the input resources for the US Core conformance check that follows.
    )

    input :anonymize_request,
          title: 'Anonymize Request (US Core)',
          description: 'US Core data to anonymize, as raw JSON or an HTTP(S) URL',
          type: 'textarea',
          optional: true

    run { validate_request(anonymize_request, policy_required: false) }
  end

  class ValidatorAnonymizeValidateRequestData < Inferno::Test
    include FlowHelpers
    id :darts_validator_anonymize_validate_request_data
    title 'Request data conforms to US Core'
    description 'Validates the collected input resources against US Core profiles.'

    run { validate_request_data(target: :us_core) }
  end

  class ValidatorAnonymizeInvoke < Inferno::Test
    include FlowHelpers
    include OperationClient
    id :darts_validator_anonymize_invoke
    title 'Invoke $anonymize on the Trust Service Provider and read the response'
    description %(
      Sends the US Core request to the Trust Service Provider's `$anonymize` endpoint
      (`POST [base]/Patient/$anonymize`) and reads the anonymized response, checking its payload
      structure and collecting the returned resources for the DAPL validation group that follows.

      The response payload form is also checked against the request's. The DARTS IG specifies that
      the two must match - a Bundle request is answered with a Bundle, and an NDJSON file-URLs
      request with file URLs - so a response that switches form fails here.
    )

    input :anonymize_request,
          title: 'Anonymize Request (US Core)',
          type: 'textarea',
          optional: true
    input :tsp_base_url,
          title: 'Trust Service Provider Base URL',
          description: 'Base URL of the Trust Service Provider under test. The operation path is appended.',
          optional: true

    run do
      response_body = invoke_operation(
        anonymize_request,
        operation_path: '/Patient/$anonymize',
        base_url: tsp_base_url
      )
      validate_response(response_body, scratch_key: :dapl_resources)
    end
  end

  class ValidatorAnonymizeSubmitGroup < Inferno::TestGroup
    id :darts_validator_anonymize_submit_group
    title 'Submit and Invoke'
    description %(
      Validates the outbound US Core request, then invokes `$anonymize` on the Trust Service Provider
      and reads the response for the DAPL validation that follows.
    )
    run_as_group

    test from: :darts_validator_anonymize_validate_request
    test from: :darts_validator_anonymize_validate_request_data
    test from: :darts_validator_anonymize_invoke
  end

  class ValidatorAnonymizeGroup < Inferno::TestGroup
    id :darts_validator_anonymize_group
    title 'Anonymize Operation ($anonymize)'
    description %(
      Validates the Trust Service Provider's `$anonymize` operation: checks the outbound US Core
      request, invokes the operation over HTTP, then validates the anonymized response, the aggregate
      `dapl-anonymized-dataset` MeasureReport, against its DAPL profile.
    )
    run_as_group

    group from: :darts_validator_anonymize_submit_group
    group from: :dapl_anonymized_dataset_validation_group
  end
end
