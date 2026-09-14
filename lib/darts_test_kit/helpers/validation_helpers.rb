require_relative '../profile_map'

module DartsTestKit
  # Profile/terminology assertions shared by the operation groups.
  module ValidationHelpers
    DARTS_BASE = 'http://hl7.org/fhir/us/darts'.freeze
    DARTS_DATA_URLS_PROFILE = "#{DARTS_BASE}/StructureDefinition/darts-operation-data-urls-parameter".freeze
    DARTS_POLICY_SYSTEM = "#{DARTS_BASE}/CodeSystem/darts-policy-identifiers".freeze
    # Codes from the darts-policy-identifier-codes value set (DARTS IG 1.0.0-ballot snapshot).
    DARTS_POLICY_CODES = %w[
      HHS_SAFE_HARBOR_DETERMINISTIC_METHOD
      HHS_EXPERT_DETERMINATION_METHOD
    ].freeze

    # Validate a data-urls Parameters resource against the DARTS profile.
    def validate_data_urls_parameters(parameters)
      assert parameters.is_a?(FHIR::Parameters),
             'Expected a Parameters resource conforming to darts-operation-data-urls-parameter, ' \
             "but found #{parameters&.resourceType || 'nothing'}."
      assert_valid_resource(resource: parameters, profile_url: DARTS_DATA_URLS_PROFILE)
    end

    # Assert the operation's `policy` is present (when required) and is a known DARTS code.
    def assert_policy(policy_code, required: true)
      if policy_code.blank?
        assert !required, 'The required `policy` parameter is missing from the operation request.'
        return
      end
      # TODO: replace with terminology-service validation once wired up; codes are a ballot snapshot.
      assert DARTS_POLICY_CODES.include?(policy_code),
             "`policy` value '#{policy_code}' is not in the DARTS Policy Identifier value set " \
             "(expected one of: #{DARTS_POLICY_CODES.join(', ')})."
    end

    # Validate each collected resource against the expected profile for `target`
    # (:us_core or :dapl). Prefers the resource's own meta.profile for that IG;
    # falls back to ProfileMap; for ambiguous/unmapped types, validates as a base resource.
    # Returns true if at least one resource was checked.
    def validate_resources(resources_by_type, target:)
      base = ProfileMap.base_for(target)
      checked = false

      resources_by_type.each do |resource_type, resources|
        resources.each do |resource|
          declared = declared_profiles(resource, base)
          if declared.any?
            declared.each { |profile_url| assert_valid_resource(resource: resource, profile_url: profile_url) }
          else
            candidates = ProfileMap.profiles_for(resource_type, target)
            if candidates.size == 1
              assert_valid_resource(resource: resource, profile_url: candidates.first)
            else
              # Unmapped, or ambiguous (e.g. Observation with no declared profile): validate as base.
              assert_valid_resource(resource: resource)
            end
          end
          checked = true
        end
      end
      checked
    end

    private

    def declared_profiles(resource, base)
      (resource.meta&.profile || []).map(&:to_s).select { |profile_url| profile_url.start_with?(base) }
    end
  end
end
