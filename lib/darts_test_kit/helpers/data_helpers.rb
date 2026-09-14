module DartsTestKit
  # Collecting the actual FHIR resources from a parsed operation payload, whether
  # supplied inline (Bundle) or by NDJSON file URLs (data-urls Parameters).
  module DataHelpers
    # Given the Hash returned by #parse_operation, return { resourceType => [FHIR models] }.
    def resources_from(parsed, bearer_token: nil)
      case parsed[:mode]
      when :data_urls
        fetch_data_url_resources(parsed[:data_urls], bearer_token: bearer_token)
      when :bundle
        collect_bundle_resources(parsed[:bundle])
      else
        {}
      end
    end

    # Fetch the NDJSON referenced by each `data` entry of a data-urls Parameters
    # resource and return { resourceType => [FHIR models] }.
    def fetch_data_url_resources(data_urls_parameters, bearer_token: nil)
      collected = Hash.new { |hash, key| hash[key] = [] }
      headers = bearer_token.present? ? { 'Authorization' => "Bearer #{bearer_token}" } : {}

      (data_urls_parameters.parameter || []).each do |param|
        next unless param.name == 'data'

        resource_type = part_value(param, 'resourceType')
        resource_url = part_value(param, 'resourceUrl')
        next if resource_url.blank?

        assert_valid_http_uri(resource_url, "Invalid resourceUrl#{" for #{resource_type}" if resource_type}: #{resource_url}")
        get(resource_url, headers: headers)
        assert_response_status(200)

        request.response_body.each_line do |line|
          next if line.strip.empty?

          assert_valid_json(line, "A line in the NDJSON at #{resource_url} is not valid JSON.")
          model = FHIR.from_contents(line)
          assert model.is_a?(FHIR::Model), "Could not parse a FHIR resource from #{resource_url}."
          collected[model.resourceType] << model
        end
      end
      collected
    end

    # Collect resources from an inline Bundle as { resourceType => [FHIR models] }.
    def collect_bundle_resources(bundle)
      collected = Hash.new { |hash, key| hash[key] = [] }
      (bundle.entry || []).each do |entry|
        next unless entry.resource

        collected[entry.resource.resourceType] << entry.resource
      end
      collected
    end

    private

    def part_value(param, part_name)
      part = (param.part || []).find { |candidate| candidate.name == part_name }
      return nil unless part

      part.valueCode || part.valueUrl || part.valueString
    end
  end
end
