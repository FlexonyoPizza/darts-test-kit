module DartsTestKit
  module ProfileMap
    US_CORE_BASE = 'http://hl7.org/fhir/us/core/StructureDefinition'.freeze

    US_CORE = {
      'Patient'            => ["#{US_CORE_BASE}/us-core-patient"],
      'Encounter'          => ["#{US_CORE_BASE}/us-core-encounter"],
      'Coverage'           => ["#{US_CORE_BASE}/us-core-coverage"],
      'Procedure'          => ["#{US_CORE_BASE}/us-core-procedure"],
      'AllergyIntolerance' => ["#{US_CORE_BASE}/us-core-allergyintolerance"],
      'Immunization'       => ["#{US_CORE_BASE}/us-core-immunization"],
      'MedicationRequest'  => ["#{US_CORE_BASE}/us-core-medicationrequest"],
      'Location'           => ["#{US_CORE_BASE}/us-core-location"],
      'Organization'       => ["#{US_CORE_BASE}/us-core-organization"],
      'RelatedPerson'      => ["#{US_CORE_BASE}/us-core-relatedperson"],
      'ServiceRequest'     => ["#{US_CORE_BASE}/us-core-servicerequest"]
    }.freeze

    TARGETS = { us_core: US_CORE }.freeze

    def self.base_for(_target)
      US_CORE_BASE
    end

    def self.profiles_for(resource_type, target)
      (TARGETS[target] || {})[resource_type] || []
    end
  end
end
