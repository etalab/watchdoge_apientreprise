describe PingStatus, type: :model do
  before do
    # Do not test here HTTPResponseValidator
    allow_any_instance_of(HTTPResponseValidator).to receive(:valid?).and_return(true)
  end

  context 'happy path' do
    subject(:ping) do
      described_class.new(
        name: name,
        api_version: api_version,
        api_name: api_name,
        date: date,
        status: status,
        environment: environment,
        http_response: http_response,
        response_regexp: response_regexp
      )
    end

    let(:name) { 'service name' }
    let(:api_version) { 2 }
    let(:api_name) { 'apie' }
    let(:date) { DateTime.now }
    let(:status) { 'up' }
    let(:environment) { 'development' }
    let(:expected_json) do
      {
        name: name,
        api_version: api_version,
        api_name: api_name,
        status: status,
        environment: environment
      }
    end
    let(:http_response) { nil }
    let(:response_regexp) { nil }

    its(:name) { is_expected.to eq(name) }
    its(:api_version) { is_expected.to eq(api_version) }
    its(:api_name) { is_expected.to eq(api_name) }
    its(:date) { is_expected.to eq(date) }
    its(:status) { is_expected.to eq(status) }
    its(:environment) { is_expected.to eq(environment) }
    its(:response_file) { is_expected.to eq("app/data/responses/#{api_name}/#{name}.json") }
    its(:valid?) { is_expected.to be_truthy }

    it 'print to json' do
      json_string = ping.to_json
      expect(json_string.class).to be(String)

      json = JSON.parse(json_string)
      expect(DateTime.parse(json['date'])).to be_within(1.second).of date
      expect(json).to include_json(expected_json)
    end

    it 'export as json' do
      json = ping.as_json

      expect(json.class).to be(Hash)
      expect(DateTime.parse(json['date'])).to be_within(1.second).of date
      expect(json).to include_json(expected_json)
    end

    context 'with non-nil http_response and response_regexp' do
      let(:response_body) do
        "{ \"key\": \"valid value\" }"
      end
      let(:http_response) { Net::HTTPResponse.new(1.0, 200, "OK") }
      let(:response_regexp) { [ { 'name' => 'test', 'regexp' => 'valid regexp' }, { 'name' => 'other test', 'regexp' => 'valid regexp'} ] }

      before do
        allow(http_response).to receive(:body).and_return(response_body) # Quite dirty test here...
        allow_any_instance_of(PingStatus).to receive(:valid_response_class).and_return(Net::HTTPResponse)
      end

      its(:json_response_body) { is_expected.to eq(JSON.parse(response_body)) }
      its(:valid?) { is_expected.to be_truthy }
    end
  end

  context 'is not valid' do
    subject { described_class.new(json_params) }

    let(:json_params) do
      {
        api_version: 5,
        api_name: 'not an api',
        date: 'not a date',
        status: 'not a status',
        environment: 'not an env'
      }
    end

    its(:valid?) { is_expected.to be_falsy }

    context 'errors message' do
      subject { described_class.new(json_params).errors.messages }

      its([:name])        { is_expected.not_to be_nil }
      its([:api_version]) { is_expected.not_to be_nil }
      its([:api_name])    { is_expected.not_to be_nil }
      its([:date])        { is_expected.not_to be_nil }
      its([:status])      { is_expected.not_to be_nil }
      its([:environment]) { is_expected.not_to be_nil }
    end
  end

  describe 'nil data' do
    subject { described_class.new(name: 'valid name', http_response: "string object",  response_regexp: [{'test' => 'missing keys'}]) }

    its(:valid?) { is_expected.to be_falsy }

    context 'errors messages' do
      subject { described_class.new(name: 'valid name').errors.messages }

      its([:name])            { is_expected.to be_empty }
      its([:api_version])     { is_expected.not_to be_nil }
      its([:api_name])        { is_expected.not_to be_nil }
      its([:date])            { is_expected.not_to be_nil }
      its([:status])          { is_expected.not_to be_nil }
      its([:environment])     { is_expected.not_to be_nil }
      its([:http_response])   { is_expected.not_to be_nil }
      its([:response_regexp]) { is_expected.not_to be_nil }
    end
  end
end
