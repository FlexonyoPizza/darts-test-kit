require 'darts_test_kit'

RSpec.describe DartsTestKit::TSP::OperationEndpoint do
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { Inferno::Repositories::TestSessions.new.create(test_suite_id: 'darts_tsp') }

  # The endpoint reads its response payload out of session data, so it needs a test run to key on.
  def endpoint_for(endpoint_class)
    endpoint_class.new.tap do |endpoint|
      allow(endpoint).to receive(:test_run).and_return(double(test_session_id: test_session.id))
    end
  end

  describe '#test_run_identifier' do
    it 'identifies the waiting run from the operation alone, with no credential on the request' do
      # No request is set on the endpoint at all, so nothing about the incoming call other than the
      # URL it was sent to can affect which run is resumed.
      expect(DartsTestKit::TSP::DeIdentifyEndpoint.new.test_run_identifier).to eq('darts-tsp-de-identify')
    end

    it 'uses a distinct identifier per operation' do
      identifiers = [
        DartsTestKit::TSP::DeIdentifyEndpoint,
        DartsTestKit::TSP::AnonymizeEndpoint,
        DartsTestKit::TSP::PseudonymizeEndpoint
      ].map { |endpoint_class| endpoint_class.new.test_run_identifier }

      expect(identifiers.uniq.length).to eq(3)
    end
  end

  describe '#configured_response_body' do
    it 'returns the bundled example when the response payload input is left blank' do
      endpoint = endpoint_for(DartsTestKit::TSP::DeIdentifyEndpoint)

      expect(endpoint.configured_response_body)
        .to eq(DartsTestKit::TSP::DeIdentifyEndpoint::DEFAULT_RESPONSE_BODY)
    end

    it 'returns the payload entered for the session' do
      custom_payload = { resourceType: 'Bundle', id: 'custom-response' }.to_json
      session_data_repo.save(
        test_session_id: test_session.id,
        name: :de_identify_response,
        value: custom_payload,
        type: 'textarea'
      )

      expect(endpoint_for(DartsTestKit::TSP::DeIdentifyEndpoint).configured_response_body).to eq(custom_payload)
    end

    it 'reads a different input per operation' do
      custom_payload = { resourceType: 'MeasureReport', id: 'custom-dataset' }.to_json
      session_data_repo.save(
        test_session_id: test_session.id,
        name: :anonymize_response,
        value: custom_payload,
        type: 'textarea'
      )

      expect(endpoint_for(DartsTestKit::TSP::AnonymizeEndpoint).configured_response_body).to eq(custom_payload)
      expect(endpoint_for(DartsTestKit::TSP::PseudonymizeEndpoint).configured_response_body)
        .to eq(DartsTestKit::TSP::PseudonymizeEndpoint::DEFAULT_RESPONSE_BODY)
    end
  end
end
