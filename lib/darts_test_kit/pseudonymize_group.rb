require_relative 'helpers/flow_helpers'

module DartsTestKit
  class PseudonymizeValidateRequest < Inferno::Test
    include FlowHelpers
    id :darts_pseudonymize_validate_request
    title 'Validate the $pseudonymize request payload'
    description %(
      Reads the `$pseudonymize` operation **request** (raw JSON or a URL) and checks its structure: any
      data-urls `Parameters` conforms to the `darts-operation-data-urls-parameter` profile, and a
      `policy`, if present, is drawn from the DARTS Policy Identifier value set. Identifiable input
      resources are collected (inline Bundle or fetched NDJSON) for the next test.
    )

    input :pseudonymize_request,
          title: 'Pseudonymize Request Payload',
          description: 'The `$pseudonymize` operation request, as raw JSON or an HTTP(S) URL.',
          type: 'textarea',
          optional: true
    input :bearer_token,
          title: 'Bearer Token (optional)',
          description: 'Sent as `Authorization: Bearer ...` when fetching data-urls NDJSON.',
          optional: true

    run { validate_request(pseudonymize_request, policy_required: false, bearer_token: bearer_token) }
  end

  class PseudonymizeValidateRequestData < Inferno::Test
    include FlowHelpers
    id :darts_pseudonymize_validate_request_data
    title 'Pseudonymize request data conforms to US Core'
    description 'Validates the identifiable input resources collected from the request against US Core profiles.'

    run { validate_request_data(target: :us_core) }
  end

  class PseudonymizeValidateResponse < Inferno::Test
    include FlowHelpers
    id :darts_pseudonymize_validate_response
    title 'Validate the $pseudonymize response payload'
    description %(
      Reads the `$pseudonymize` operation **response** (raw JSON or a URL) and checks its structure: any
      data-urls `Parameters` conforms to the `darts-operation-data-urls-parameter` profile. The
      pseudonymized output resources are collected for the next test.
    )

    input :pseudonymize_response,
          title: 'Pseudonymize Response Payload',
          description: 'The `$pseudonymize` operation response, as raw JSON or an HTTP(S) URL.',
          type: 'textarea',
          optional: true
    input :bearer_token,
          title: 'Bearer Token (optional)',
          description: 'Sent as `Authorization: Bearer ...` when fetching data-urls NDJSON.',
          optional: true

    run { validate_response(pseudonymize_response, bearer_token: bearer_token) }
  end

  class PseudonymizeValidateResponseData < Inferno::Test
    include FlowHelpers
    id :darts_pseudonymize_validate_response_data
    title 'Pseudonymize response data conforms to US Core'
    description %(
      Validates the pseudonymized output resources against US Core profiles. Pseudonymized data is
      still PHI and retains its US Core structure, so it is validated against US Core rather than DAPL.
    )

    run { validate_response_data(target: :us_core) }
  end

  class PseudonymizeGroup < Inferno::TestGroup
    id :darts_pseudonymize_group
    title 'Pseudonymize Operation ($pseudonymize)'
    description %(
      Validates the payloads of the DARTS `$pseudonymize` operation: the request (identifiable US Core
      data) and the response (pseudonymized data, which remains PHI and is validated against US Core).
      No live server is required - provide the request and/or response payloads as inputs.
    )
    run_as_group

    test from: :darts_pseudonymize_validate_request
    test from: :darts_pseudonymize_validate_request_data
    test from: :darts_pseudonymize_validate_response
    test from: :darts_pseudonymize_validate_response_data
  end
end
