require_relative 'operation_endpoint'

module DartsTestKit
  module TSP
    # `$pseudonymize`: returns a Bundle of **US Core** resources whose direct identifiers have been
    # replaced with pseudonym tokens. The output is still individual-level, re-identifiable PHI, so it
    # stays under US Core - DAPL de-identified profiles do not apply.
    class PseudonymizeEndpoint < OperationEndpoint
      WAIT_IDENTIFIER = 'darts-tsp-pseudonymize'.freeze
      DEFAULT_RESPONSE_BODY = response_fixture('pseudonymized_bundle.json')
      RESPONSE_INPUT = :pseudonymize_response
      REQUEST_TAG = 'pseudonymize_request'.freeze
    end
  end
end
