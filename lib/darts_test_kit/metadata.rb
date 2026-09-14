require_relative 'version'

module DartsTestKit
  class Metadata < Inferno::TestKit
    id :darts
    title 'DARTS Test Kit'
    description <<~DESCRIPTION
      The DARTS Test Kit validates conformance to the [DARTS (De-Identification, Anonymization,
      Redaction Toolkit Services) Implementation Guide v1.0.0-ballot](https://build.fhir.org/ig/HL7/fhir-darts/).
      DARTS defines server-side services (`$de-identify`, `$anonymize`, `$pseudonymize`) that transform
      identifiable US Core data into de-identified, anonymized, or pseudonymized output.

      <!-- break -->

      ## Getting Started

      Use the **DARTS Client Suite** to test a Trust Service Provider. Inferno acts as the Data
      Submitter: point the suite at the base URL of the system under test, and for each operation it
      sends US Core input, invokes the operation over HTTP, and validates the response. Output is
      checked against the specification appropriate to that operation:

      - `$de-identify` - each returned resource against its individual
        [DAPL](https://build.fhir.org/ig/HL7/fhir-dapl/) profile.
      - `$anonymize` - the aggregate `dapl-anonymized-dataset` MeasureReport.
      - `$pseudonymize` - against US Core, since pseudonymized records remain individual-level,
        re-identifiable PHI rather than de-identified data.

      ## Status

      These tests are a **DRAFT** built against ballot versions of the DARTS and DAPL IGs and will change
      as those guides mature.

      ## Providing Feedback and Reporting Issues

      Please report any issues with this set of tests in the issues section of the repository.
    DESCRIPTION

    # Suites shown on the test kit landing page:
    #   darts_validator - Client Suite: tests a Trust Service Provider's DARTS operations.
    #   darts_tsp       - Server Suite: simulates a TSP, for use when no real one is available.
    # (The legacy passive payload suite is still reachable at /darts.)
    suite_ids [:darts_validator, :darts_tsp]
    tags ['De-Identification', 'DARTS']
    last_updated LAST_UPDATED
    version VERSION
    maturity 'Low'
    authors ['leon11']
    # repo 'TODO'
  end
end
