require_relative 'operation_endpoint'

module DartsTestKit
  module TSP
    # `$anonymize`: returns the aggregate `dapl-anonymized-dataset` MeasureReport - population-level
    # statistics, not individual records.
    class AnonymizeEndpoint < OperationEndpoint
      WAIT_IDENTIFIER = 'darts-tsp-anonymize'.freeze
      DEFAULT_RESPONSE_BODY = response_fixture('anonymized_dataset.json')
      RESPONSE_INPUT = :anonymize_response
      REQUEST_TAG = 'anonymize_request'.freeze
    end
  end
end
