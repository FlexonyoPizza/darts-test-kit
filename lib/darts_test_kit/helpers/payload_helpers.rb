module DartsTestKit
  # Reading and structurally interpreting an operation request/response payload.
  module PayloadHelpers
    # Read a payload supplied as raw JSON or as an HTTP(S) URL; return the FHIR model.
    def read_payload(payload, label)
      assert payload.present?, "No #{label} was provided."
      json =
        if payload.strip.start_with?('{')
          payload
        else
          assert_valid_http_uri(payload, "#{label} is neither raw JSON nor a valid URL.")
          get(payload)
          assert_response_status(200)
          request.response_body
        end
      assert_valid_json(json, "#{label} is not valid JSON.")
      model = FHIR.from_contents(json)
      assert model.is_a?(FHIR::Model), "#{label} could not be parsed into a FHIR resource."
      model
    end

    # Interpret an operation request/response payload. DARTS operations accept/return
    # data either inline (a Bundle) or by reference (a darts-operation-data-urls-parameter
    # Parameters). The payload may be the bare data component, or the full operation
    # Parameters wrapping it (plus `policy`). Detection is by resource type, so it is
    # robust to the differing output parameter names across the three operations.
    #
    # Returns { mode: :data_urls|:bundle|:unknown, data_urls:, bundle:, policy_code:, wrapped: }
    def parse_operation(model)
      result = { mode: :unknown, data_urls: nil, bundle: nil, policy_code: nil, wrapped: false }

      if model.is_a?(FHIR::Bundle)
        return result.merge(mode: :bundle, bundle: model)
      end

      return result unless model.is_a?(FHIR::Parameters)

      return result.merge(mode: :data_urls, data_urls: model) if data_urls_parameters?(model)

      # Outer operation Parameters wrapping the data component + policy.
      result[:wrapped] = true
      result[:policy_code] = policy_code(model)
      nested = (model.parameter || []).map(&:resource).compact
      if (data_urls = nested.find { |resource| resource.is_a?(FHIR::Parameters) })
        result.merge!(mode: :data_urls, data_urls: data_urls)
      elsif (bundle = nested.find { |resource| resource.is_a?(FHIR::Bundle) })
        result.merge!(mode: :bundle, bundle: bundle)
      end
      result
    end

    private

    def data_urls_parameters?(parameters)
      names = (parameters.parameter || []).map(&:name)
      names.include?('data') || names.include?('format')
    end

    def policy_code(parameters)
      policy = (parameters.parameter || []).find { |param| param.name == 'policy' }
      policy&.valueString || policy&.valueCode
    end
  end
end
