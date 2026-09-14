require_relative 'helpers/flow_helpers'
require 'dapl_test_kit/groups/dapl_anonymized_dataset_validation_group'

module DartsTestKit
  class AnonymizeValidateRequest < Inferno::Test
    include FlowHelpers
    id :darts_anonymize_validate_request
    title 'Validate the $anonymize request payload'
    description %(
      Reads the `$anonymize` operation **request** (raw JSON or a URL) and checks its structure: any
      data-urls `Parameters` conforms to the `darts-operation-data-urls-parameter` profile, and a
      `policy`, if present, is drawn from the DARTS Policy Identifier value set. Identifiable input
      resources are collected (inline Bundle or fetched NDJSON) for the next test.
    )

    input :anonymize_request,
          title: 'Anonymize Request Payload',
          description: 'The `$anonymize` operation request, as raw JSON or an HTTP(S) URL.',
          type: 'textarea',
          optional: true
    input :bearer_token,
          title: 'Bearer Token (optional)',
          description: 'Sent as `Authorization: Bearer ...` when fetching data-urls NDJSON.',
          optional: true

    run { validate_request(anonymize_request, policy_required: false, bearer_token: bearer_token) }
  end

  class AnonymizeValidateRequestData < Inferno::Test
    include FlowHelpers
    id :darts_anonymize_validate_request_data
    title 'Anonymize request data conforms to US Core'
    description 'Validates the identifiable input resources collected from the request against US Core profiles.'

    run { validate_request_data(target: :us_core) }
  end

  class AnonymizeValidateResponse < Inferno::Test
    include FlowHelpers
    id :darts_anonymize_validate_response
    title 'Validate the $anonymize response payload'
    description %(
      Reads the `$anonymize` operation **response** (raw JSON or a URL) and checks its structure: any
      data-urls `Parameters` conforms to the `darts-operation-data-urls-parameter` profile. The
      anonymized output resources are collected for the DAPL Resource Validation group that follows.
    )

    input :anonymize_response,
          title: 'Anonymize Response Payload',
          description: 'The `$anonymize` operation response, as raw JSON or an HTTP(S) URL.',
          type: 'textarea',
          optional: true
    input :bearer_token,
          title: 'Bearer Token (optional)',
          description: 'Sent as `Authorization: Bearer ...` when fetching data-urls NDJSON.',
          optional: true

    run { validate_response(anonymize_response, bearer_token: bearer_token, scratch_key: :dapl_resources) }
  end

  class AnonymizeGroup < Inferno::TestGroup
    id :darts_anonymize_group
    title 'Anonymize Operation ($anonymize)'
    description %(
      Validates the payloads of the DARTS `$anonymize` operation: the request (identifiable US Core
      data) and the response (the anonymized dataset MeasureReport conforming to the
      `dapl-anonymized-dataset` profile), validated by the composed DAPL Anonymized Dataset
      Validation group. No live server is required - provide the request and/or response payloads as
      inputs.
    )
    run_as_group

    test from: :darts_anonymize_validate_request
    test from: :darts_anonymize_validate_request_data
    test from: :darts_anonymize_validate_response
    # The DAPL seam: validation of the anonymized-dataset MeasureReport output (reads scratch[:dapl_resources]).
    group from: :dapl_anonymized_dataset_validation_group
  end
end
