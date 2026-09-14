require 'darts_test_kit'

# The DARTS IG specifies that an operation's output payload form matches its input payload form:
# a Bundle request is answered with a Bundle, an NDJSON file-URLs request with file URLs.
RSpec.describe DartsTestKit::FlowHelpers do
  # A minimal host for the helpers, with Inferno's assertions and HTTP stubbed out.
  TestHost = Class.new do
    include DartsTestKit::FlowHelpers

    attr_reader :scratch, :request

    def initialize
      @scratch = {}
    end

    def assert(condition, message = 'assertion failed')
      raise Inferno::Exceptions::AssertionException, message unless condition
    end

    def omit_if(*); end
    def add_message(*); end
    def assert_valid_json(*); end
    def assert_valid_http_uri(*); end
    def assert_valid_resource(**); end
    def assert_response_status(*); end

    # An empty NDJSON body: collects no resources, but exercises the fetch path without network.
    def get(*)
      @request = Struct.new(:response_body).new('')
    end
  end

  let(:bundle_payload) do
    {
      resourceType: 'Parameters',
      parameter: [
        { name: 'identifiableData', resource: { resourceType: 'Bundle', type: 'collection', entry: [] } },
        { name: 'policy', valueString: 'HHS_SAFE_HARBOR_DETERMINISTIC_METHOD' }
      ]
    }.to_json
  end

  let(:data_urls_payload) do
    {
      resourceType: 'Parameters',
      parameter: [
        { name: 'identifiableDataFileUrls', resource: {
          resourceType: 'Parameters',
          parameter: [
            { name: 'format', valueCode: 'fhir+ndjson' },
            { name: 'data', part: [
              { name: 'resourceType', valueCode: 'Patient' },
              { name: 'resourceUrl', valueUrl: 'https://example.org/Patient.ndjson' }
            ] }
          ]
        } }
      ]
    }.to_json
  end

  let(:test_host) { TestHost.new }

  def exchange(host, request_payload, response_payload)
    host.validate_request(request_payload, policy_required: false)
    host.validate_response(response_payload)
  end

  it 'accepts a Bundle response to a Bundle request' do
    expect { exchange(test_host, bundle_payload, bundle_payload) }.to_not raise_error
    expect(test_host.scratch[:request_mode]).to eq(:bundle)
  end

  it 'accepts a file-URLs response to a file-URLs request' do
    expect { exchange(test_host, data_urls_payload, data_urls_payload) }.to_not raise_error
    expect(test_host.scratch[:request_mode]).to eq(:data_urls)
  end

  it 'rejects a file-URLs response to a Bundle request' do
    expect { exchange(test_host, bundle_payload, data_urls_payload) }
      .to raise_error(Inferno::Exceptions::AssertionException, /returned NDJSON file URLs.*sent as an inline Bundle/m)
  end

  it 'rejects a Bundle response to a file-URLs request' do
    expect { exchange(test_host, data_urls_payload, bundle_payload) }
      .to raise_error(Inferno::Exceptions::AssertionException, /returned an inline Bundle.*sent as NDJSON file URLs/m)
  end

  it 'skips the check when no request was recorded' do
    # A response validated on its own has nothing to compare against.
    expect { test_host.validate_response(bundle_payload) }.to_not raise_error
  end
end
