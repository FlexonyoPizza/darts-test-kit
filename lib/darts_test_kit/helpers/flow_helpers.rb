require_relative 'payload_helpers'
require_relative 'data_helpers'
require_relative 'validation_helpers'

module DartsTestKit
  # High-level orchestration shared by all three operation groups. Including this
  # module also brings in the payload, data, and validation helpers.
  module FlowHelpers
    include PayloadHelpers
    include DataHelpers
    include ValidationHelpers

    # Read + structurally validate an operation request, then collect its input resources.
    def validate_request(request_payload, policy_required:, bearer_token: nil)
      omit_if request_payload.blank?, 'No operation request was provided.'
      parsed = parse_operation(read_payload(request_payload, 'operation request'))
      assert parsed[:mode] != :unknown,
             'Could not find identifiable data (a data-urls Parameters or a Bundle) in the request.'
      validate_data_urls_parameters(parsed[:data_urls]) if parsed[:mode] == :data_urls
      if parsed[:wrapped]
        assert_policy(parsed[:policy_code], required: policy_required)
      elsif policy_required
        add_message('info',
                    'Provide the full operation request Parameters (including `policy`) to validate the policy code.')
      end
      # Remembered so the response can be checked against it: the DARTS operations return the same
      # form they were given (see #assert_matching_payload_form).
      scratch[:request_mode] = parsed[:mode]
      scratch[:input_resources] = resources_from(parsed, bearer_token: bearer_token)
    end

    # Validate the previously collected input resources against US Core.
    def validate_request_data(target: :us_core)
      collected = scratch[:input_resources] || {}
      omit_if collected.values.all?(&:empty?), 'No input resources were collected from the request.'
      validate_resources(collected, target: target)
    end

    # Read + structurally validate an operation response, then collect its output resources into
    # `scratch[scratch_key]`. De-identify/anonymize collect into :dapl_resources (consumed by the
    # composed DAPL resource-validation group); pseudonymize keeps :output_resources (validated
    # against US Core by this kit's own response-data test).
    def validate_response(response_payload, bearer_token: nil, scratch_key: :output_resources)
      omit_if response_payload.blank?, 'No operation response was provided.'
      parsed = parse_operation(read_payload(response_payload, 'operation response'))
      assert parsed[:mode] != :unknown,
             'Could not find transformed data (a data-urls Parameters or a Bundle) in the response.'
      validate_data_urls_parameters(parsed[:data_urls]) if parsed[:mode] == :data_urls
      assert_matching_payload_form(parsed[:mode])
      scratch[scratch_key] = resources_from(parsed, bearer_token: bearer_token)
    end

    # The response must come back in the same form the request was sent in. Skipped when the request
    # mode is unknown (e.g. a response validated on its own, without a preceding request).
    def assert_matching_payload_form(response_mode)
      request_mode = scratch[:request_mode]
      return if request_mode.blank? || request_mode == :unknown

      assert response_mode == request_mode,
             "The Trust Service Provider returned #{PAYLOAD_FORM_NAMES[response_mode]}, but the " \
             "request was sent as #{PAYLOAD_FORM_NAMES[request_mode]}. The DARTS IG specifies that " \
             'the output payload form must match the input payload form: the OperationDefinition ' \
             'documents the file-URLs output as returned when the input is a set of NDJSON file ' \
             'URLs only, and the Bundle output as returned when the input is a Bundle only.'
    end

    PAYLOAD_FORM_NAMES = {
      bundle: 'an inline Bundle',
      data_urls: 'NDJSON file URLs'
    }.freeze

    # Validate the previously collected output resources against the target IG.
    def validate_response_data(target:)
      collected = scratch[:output_resources] || {}
      omit_if collected.values.all?(&:empty?), 'No output resources were collected from the response.'
      validate_resources(collected, target: target)
    end
  end
end
