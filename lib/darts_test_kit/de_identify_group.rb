require_relative 'helpers/flow_helpers'
require 'dapl_test_kit/groups/dapl_deidentified_resource_validation_group'

module DartsTestKit
  class DeIdentifyValidateRequest < Inferno::Test
    include FlowHelpers
    id :darts_de_identify_validate_request
    title 'Validate the $de-identify request payload'
    description %(
      Reads the `$de-identify` operation **request** (raw JSON or a URL) and checks its structure:
      any data-urls `Parameters` conforms to the `darts-operation-data-urls-parameter` profile, and
      the required `policy` is drawn from the DARTS Policy Identifier value set. Identifiable input
      resources are collected (from an inline Bundle or by fetching the referenced NDJSON) for the
      next test.
    )

    input :de_identify_request,
          title: 'De-Identify Request Payload',
          description: 'The `$de-identify` operation request, as raw JSON or an HTTP(S) URL.',
          type: 'textarea',
          optional: true
    input :bearer_token,
          title: 'Bearer Token (optional)',
          description: 'Sent as `Authorization: Bearer ...` when fetching data-urls NDJSON.',
          optional: true

    run { validate_request(de_identify_request, policy_required: true, bearer_token: bearer_token) }
  end

  class DeIdentifyValidateRequestData < Inferno::Test
    include FlowHelpers
    id :darts_de_identify_validate_request_data
    title 'De-identify request data conforms to US Core'
    description 'Validates the identifiable input resources collected from the request against US Core profiles.'

    run { validate_request_data(target: :us_core) }
  end

  class DeIdentifyValidateResponse < Inferno::Test
    include FlowHelpers
    id :darts_de_identify_validate_response
    title 'Validate the $de-identify response payload'
    description %(
      Reads the `$de-identify` operation **response** (raw JSON or a URL) and checks its structure:
      any data-urls `Parameters` conforms to the `darts-operation-data-urls-parameter` profile. The
      de-identified output resources are collected for the DAPL Resource Validation group that follows.
    )

    input :de_identify_response,
          title: 'De-Identify Response Payload',
          description: 'The `$de-identify` operation response, as raw JSON or an HTTP(S) URL.',
          type: 'textarea',
          optional: true
    input :bearer_token,
          title: 'Bearer Token (optional)',
          description: 'Sent as `Authorization: Bearer ...` when fetching data-urls NDJSON.',
          optional: true

    run { validate_response(de_identify_response, bearer_token: bearer_token, scratch_key: :dapl_resources) }
  end

  class DeIdentifyGroup < Inferno::TestGroup
    id :darts_de_identify_group
    title 'De-Identify Operation ($de-identify)'
    description %(
      Validates the payloads of the DARTS `$de-identify` operation: the request (identifiable US Core
      data + a required `policy`) and the response (de-identified data conforming to DAPL profiles).
      The de-identified output is validated, resource by resource, by the composed DAPL De-identified
      Resource Validation group. No live server is required - provide the request and/or response
      payloads as inputs.
    )
    run_as_group

    test from: :darts_de_identify_validate_request
    test from: :darts_de_identify_validate_request_data
    test from: :darts_de_identify_validate_response
    # The DAPL seam: per-resource DAPL validation of the de-identified output (reads scratch[:dapl_resources]).
    group from: :dapl_deidentified_resource_validation_group
  end
end
