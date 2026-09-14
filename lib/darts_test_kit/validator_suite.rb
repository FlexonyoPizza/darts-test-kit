require_relative 'metadata'
require_relative 'version'
require_relative 'validator/access_token_group'
require_relative 'validator/de_identify_group'
require_relative 'validator/anonymize_group'
require_relative 'validator/pseudonymize_group'

module DartsTestKit
  class DARTSValidatorSuite < Inferno::TestSuite
    id :darts_validator
    title 'DARTS Client Suite (Data Submitter)'
    short_title 'DARTS Validator'
    description <<~DESCRIPTION
      Validates a **Trust Service Provider's** conformance to the DARTS operations. Inferno acts as the
      Data Submitter: for each operation it sends US Core input to the TSP under test, then validates
      the operation response - its payload structure, and the transformed resources it contains.

      Point the **Trust Service Provider Base URL** input at the system under test. That URL is all
      the configuration requires: each operation is invoked at that base URL (for example
      `POST [base]/Patient/$de-identify`).

      Authorization is optional and is configured in one place. If the Trust Service Provider is
      secured with OAuth2 client credentials (SMART Backend Services), run the **Obtain Access Token**
      group first; the token it obtains is sent automatically on the operation calls that follow.

      Output is validated against the specification appropriate to each operation:

      - `$de-identify` - each resource against its individual
        [DAPL](https://build.fhir.org/ig/HL7/fhir-dapl/) profile.
      - `$anonymize` - the aggregate `dapl-anonymized-dataset` MeasureReport.
      - `$pseudonymize` - against **US Core**, since pseudonymized records remain individual-level,
        re-identifiable PHI rather than de-identified data.

      This test kit also bundles a
      **DARTS Server Suite** that simulates a Trust Service Provider, so these tests can be exercised end to end. It is a
      development and demonstration aid only - it is not required, and testing a real TSP does not
      involve it.
    DESCRIPTION

    links [
      { type: 'report_issue', label: 'Report Issue', url: 'https://github.com/inferno-framework/darts-test-kit/issues' },
      { type: 'source_code', label: 'Open Source', url: 'https://github.com/inferno-framework/darts-test-kit' },
      { type: 'download', label: 'Download', url: 'https://github.com/inferno-framework/darts-test-kit/releases' },
      { type: 'ig', label: 'DARTS Implementation Guide v1.0.0-ballot', url: 'https://build.fhir.org/ig/HL7/fhir-darts/' }
    ]

    fhir_resource_validator do
      igs "hl7.fhir.us.darts##{DARTS_VERSION}",
          "hl7.fhir.us.dapl##{DAPL_VERSION}",
          "hl7.fhir.us.core##{US_CORE_VERSION}"

      validation_context do
        txServer nil
      end

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/) ||
          message.message.match?(/Example URLs are not allowed in this context/) ||
          message.message.match?(/dom-6/)
      end
    end

    group from: :darts_validator_obtain_access_token_group
    group from: :darts_validator_de_identify_group
    group from: :darts_validator_anonymize_group
    group from: :darts_validator_pseudonymize_group
  end
end
