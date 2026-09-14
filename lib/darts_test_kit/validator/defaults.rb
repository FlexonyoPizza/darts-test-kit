module DartsTestKit
  # Shared defaults for the Validator Suite's operation groups (de-identify, anonymize, pseudonymize).

  # Default US Core request the Validator sends (a published US Core Patient in a Bundle).
  US_CORE_REQUEST_BUNDLE =
    File.read(File.join(__dir__, '..', 'examples', 'us_core_request_bundle.json')).freeze

  # Convenience default pointing at the bundled Server Suite in the same Inferno instance. Replace it
  # with the base URL of the Trust Service Provider under test.
  TSP_BASE_URL_DEFAULT = 'http://localhost:4567/custom/darts_tsp'.freeze
end
