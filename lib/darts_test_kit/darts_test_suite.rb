require_relative 'metadata'
require_relative 'version'
require_relative 'de_identify_group'
require_relative 'anonymize_group'
require_relative 'pseudonymize_group'

module DartsTestKit
  class DARTSTestSuite < Inferno::TestSuite
    id :darts
    title 'DARTS Test Kit'
    short_title 'DARTS'
    description <<~DESCRIPTION
      Validates conformance to the [DARTS Implementation Guide v1.0.0-ballot](https://build.fhir.org/ig/HL7/fhir-darts/).

      These tests focus on **operations conformance** for `$de-identify`, `$anonymize`, and
      `$pseudonymize`. They validate the structure of the operation request and response payloads -
      the `darts-operation-data-urls-parameter` Parameters profile, the `policy` code, and the
      referenced data - without requiring a live DARTS server. Provide the request and/or response
      payloads (raw JSON or a URL) as inputs to each operation group.

      Output resources are validated against [DAPL](https://build.fhir.org/ig/HL7/fhir-dapl/) profiles
      (de-identify / anonymize) or US Core (pseudonymize, which remains PHI).
    DESCRIPTION

    links [
      {
        type: 'report_issue',
        label: 'Report Issue',
        url: 'https://github.com/inferno-framework/darts-test-kit/issues'
      },
      {
        type: 'source_code',
        label: 'Open Source',
        url: 'https://github.com/inferno-framework/darts-test-kit'
      },
      {
        type: 'download',
        label: 'Download',
        url: 'https://github.com/inferno-framework/darts-test-kit/releases'
      },
      {
        type: 'ig',
        label: 'DARTS Implementation Guide v1.0.0-ballot',
        url: 'https://build.fhir.org/ig/HL7/fhir-darts/'
      }
    ]

    # FHIR validation uses the DARTS, DAPL, and US Core IGs.
    # NOTE: ballot packages may not be on the public FHIR registry. If `igs '<id>#<version>'`
    # fails to resolve, download the package .tgz into lib/darts_test_kit/igs/ and instead use
    # e.g. `igs 'igs/hl7.fhir.us.darts.tgz'`.
    fhir_resource_validator do
      igs "hl7.fhir.us.darts##{DARTS_VERSION}",
          "hl7.fhir.us.dapl##{DAPL_VERSION}",
          "hl7.fhir.us.core##{US_CORE_VERSION}"

      validation_context do
        txServer nil
      end

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    examples_dir = File.join(__dir__, 'examples')
    {
      'data_urls_parameters' => 'data_urls_parameters_example.json',
      'operation_request' => 'operation_request_example.json'
    }.each do |route_name, filename|
      contents = File.read(File.join(examples_dir, filename))
      route(:get, "/examples/#{route_name}", proc { [200, { 'Content-Type' => 'application/json' }, [contents]] })
    end

    group from: :darts_de_identify_group
    group from: :darts_anonymize_group
    group from: :darts_pseudonymize_group
  end
end
