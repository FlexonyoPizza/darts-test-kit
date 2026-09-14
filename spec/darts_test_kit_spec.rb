require 'darts_test_kit'

RSpec.describe DartsTestKit, order: :defined do
  it_behaves_like 'platform_deployable_test_kit'
end
