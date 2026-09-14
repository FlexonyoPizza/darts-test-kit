require_relative '../helpers/flow_helpers'
require_relative '../helpers/operation_client'
require_relative 'defaults'

# NOTE: no DAPL group is composed here. Pseudonymized output is still individual-level,
# re-identifiable PHI: the identifiers are replaced with tokens, but the records are not
# de-identified, so DAPL profiles do not apply. The output keeps its US Core structure and is
# validated against US Core by this kit's own response-data test.
module DartsTestKit
  class ValidatorPseudonymizeValidateRequest < Inferno::Test
    include FlowHelpers
    id :darts_validator_pseudonymize_validate_request
    title 'Validate the $pseudonymize request payload'
    description %(
      Reads the US Core data that will be sent to `$pseudonymize` and checks its structure, collecting
      the input resources for the US Core conformance check that follows.
    )

    input :pseudonymize_request,
          title: 'Pseudonymize Request (US Core)',
          description: 'US Core data to pseudonymize, as raw JSON or an HTTP(S) URL',
          type: 'textarea',
          optional: true

    run { validate_request(pseudonymize_request, policy_required: false) }
  end

  class ValidatorPseudonymizeValidateRequestData < Inferno::Test
    include FlowHelpers
    id :darts_validator_pseudonymize_validate_request_data
    title 'Request data conforms to US Core'
    description 'Validates the collected input resources against US Core profiles.'

    run { validate_request_data(target: :us_core) }
  end

  class ValidatorPseudonymizeInvoke < Inferno::Test
    include FlowHelpers
    include OperationClient
    id :darts_validator_pseudonymize_invoke
    title 'Invoke $pseudonymize on the Trust Service Provider and read the response'
    description %(
      Sends the US Core request to the Trust Service Provider's `$pseudonymize` endpoint
      (`POST [base]/Patient/$pseudonymize`) and reads the pseudonymized response, checking its payload
      structure and collecting the returned resources for the US Core check that follows.
    )

    input :pseudonymize_request,
          title: 'Pseudonymize Request (US Core)',
          type: 'textarea',
          optional: true
    input :tsp_base_url,
          title: 'Trust Service Provider Base URL',
          description: 'Base URL of the Trust Service Provider under test. The operation path is appended.',
          optional: true

    run do
      response_body = invoke_operation(
        pseudonymize_request,
        operation_path: '/Patient/$pseudonymize',
        base_url: tsp_base_url
      )
      # Default scratch key (:output_resources), NOT :dapl_resources, since no DAPL group runs here.
      validate_response(response_body)
    end
  end

  class ValidatorPseudonymizeValidateResponseData < Inferno::Test
    include FlowHelpers
    id :darts_validator_pseudonymize_validate_response_data
    title 'Response data conforms to US Core'
    description %(
      Validates the pseudonymized output resources against US Core profiles. Pseudonymized data is
      still PHI and retains its US Core structure, so it is validated against US Core rather than DAPL.
    )

    run { validate_response_data(target: :us_core) }
  end

  class ValidatorPseudonymizeGroup < Inferno::TestGroup
    id :darts_validator_pseudonymize_group
    title 'Pseudonymize Operation ($pseudonymize)'
    description %(
      Validates the Trust Service Provider's `$pseudonymize` operation: checks the outbound US Core
      request, invokes the operation over HTTP, then validates the pseudonymized response against
      **US Core** rather than DAPL. Pseudonymized records remain individual-level, re-identifiable PHI
      (real identifiers swapped for tokens), so the DAPL de-identified profiles do not apply.
    )
    run_as_group

    test from: :darts_validator_pseudonymize_validate_request
    test from: :darts_validator_pseudonymize_validate_request_data
    test from: :darts_validator_pseudonymize_invoke
    test from: :darts_validator_pseudonymize_validate_response_data
  end
end
