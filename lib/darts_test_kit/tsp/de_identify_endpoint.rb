require_relative 'operation_endpoint'

module DartsTestKit
  module TSP
    # `$de-identify`: returns a Bundle of de-identified DAPL resources (a published, conformant
    # example from the DAPL IG).
    class DeIdentifyEndpoint < OperationEndpoint
      WAIT_IDENTIFIER = 'darts-tsp-de-identify'.freeze
      DEFAULT_RESPONSE_BODY = response_fixture('de_identified_bundle.json')
      RESPONSE_INPUT = :de_identify_response
      REQUEST_TAG = 'de_identify_request'.freeze
    end
  end
end
