require 'darts_test_kit'

RSpec.describe DartsTestKit::OperationClient do
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { Inferno::Repositories::TestSessions.new.create(test_suite_id: 'darts_validator') }
  let(:invoke_test) { DartsTestKit::ValidatorDeIdentifyInvoke.new(test_session_id: test_session.id) }

  describe '#access_token' do
    it 'is absent when the Obtain Access Token group has not been run' do
      expect(invoke_test.access_token).to be_blank
    end

    it 'picks up the token that group stored for the session' do
      session_data_repo.save(
        test_session_id: test_session.id,
        name: :bearer_token,
        value: 'token-from-oauth-group',
        type: 'text'
      )

      expect(invoke_test.access_token).to eq('token-from-oauth-group')
    end
  end

  describe 'operation group inputs' do
    it 'never asks for a bearer token' do
      invoke_test_classes = [
        DartsTestKit::ValidatorDeIdentifyInvoke,
        DartsTestKit::ValidatorAnonymizeInvoke,
        DartsTestKit::ValidatorPseudonymizeInvoke
      ]

      invoke_test_classes.each do |invoke_test_class|
        expect(invoke_test_class.inputs.map(&:name)).to_not include(:bearer_token)
      end
    end
  end
end
