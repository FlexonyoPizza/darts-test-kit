require_relative 'metadata'
require_relative 'version'
require_relative 'tsp/de_identify_endpoint'
require_relative 'tsp/anonymize_endpoint'
require_relative 'tsp/pseudonymize_endpoint'
require_relative 'tsp/de_identify_request_group'
require_relative 'tsp/anonymize_request_group'
require_relative 'tsp/pseudonymize_request_group'

module DartsTestKit
  # A stand-in Trust Service Provider for development and demonstration. It exposes the three DARTS
  # operation endpoints, checks that each inbound call is a well-formed operation request, and returns
  # the response payload configured for the session.
  # Supplementary only: testing a real TSP uses the DARTS Client Suite on its own.
  class DARTSTSPSuite < Inferno::TestSuite
    id :darts_tsp
    title 'DARTS Server Suite (Trust Service Provider Simulator)'
    short_title 'DARTS TSP'
    description <<~DESCRIPTION
      Simulates a **Trust Service Provider** so the DARTS Client Suite can be exercised end to end
      without a real implementation. It exposes the three DARTS operation endpoints, checks that each
      inbound call is a well-formed operation request, and returns the de-identified, anonymized, or
      pseudonymized payload configured for that operation. Each group's inputs include the exact
      response payload it will return, so it can be edited to exercise a different response.

      US Core conformance of the submitted data is not graded here. Sending conformant data is the
      Data Submitter's responsibility, so the **DARTS Client Suite** validates it against US Core
      before the operation is invoked.

      This suite is a development and demonstration aid. When testing an actual Trust Service Provider,
      use the **DARTS Client Suite** on its own and point it at that system.

      To exercise both halves of an exchange here, start a group in this suite first: its receive test
      waits for an incoming call. Then run the matching group in the DARTS Client Suite, with its
      Trust Service Provider Base URL set to this suite's endpoints. No credentials are involved -
      the URL is the only thing the two sides need to agree on:

      - `.../custom/darts_tsp/Patient/$de-identify`
      - `.../custom/darts_tsp/Patient/$anonymize`
      - `.../custom/darts_tsp/Patient/$pseudonymize`
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

      # Disabled the tx server for now, re-enable when necessary. 
      validation_context do
        txServer nil
      end

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/) ||
          message.message.match?(/Example URLs are not allowed in this context/) ||
          message.message.match?(/dom-6/)
      end
    end

    suite_endpoint :post, '/Patient/$de-identify', TSP::DeIdentifyEndpoint
    suite_endpoint :post, '/Patient/$anonymize', TSP::AnonymizeEndpoint
    suite_endpoint :post, '/Patient/$pseudonymize', TSP::PseudonymizeEndpoint

    group from: :darts_tsp_de_identify_request_group
    group from: :darts_tsp_anonymize_request_group
    group from: :darts_tsp_pseudonymize_request_group
  end
end
