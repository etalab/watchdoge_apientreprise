describe PingStatus, type: :model do
  context 'happy path' do
    subject(:ping) { described_class.new(name: name, api_version: api_version, date: date, status: status, environment: environment) }

    let(:name) { 'service name' }
    let(:api_version) { 2 }
    let(:date) { DateTime.now }
    let(:status) { 'up' }
    let(:environment) { 'development' }
    let(:expected_json) do
      {
        name: name,
        api_version: api_version,
        status: status,
        environment: environment
      }
    end

    its(:name) { is_expected.to eq(name) }
    its(:api_version) { is_expected.to eq(api_version) }
    its(:date) { is_expected.to eq(date) }
    its(:status) { is_expected.to eq(status) }
    its(:environment) { is_expected.to eq(environment) }
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
  end

  context 'is not valid' do
    subject { described_class.new(json_params) }

    let(:json_params) do
      {
        api_version: 5,
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
      its([:date])        { is_expected.not_to be_nil }
      its([:status])      { is_expected.not_to be_nil }
      its([:environment]) { is_expected.not_to be_nil }
    end
  end

  describe 'nil data' do
    subject { described_class.new(name: 'valid name') }

    its(:valid?) { is_expected.to be_falsy }

    context 'errors messages' do
      subject { described_class.new(name: 'valid name').errors.messages }

      its([:name])        { is_expected.to be_empty }
      its([:api_version]) { is_expected.not_to be_nil }
      its([:date])        { is_expected.not_to be_nil }
      its([:status])      { is_expected.not_to be_nil }
      its([:environment]) { is_expected.not_to be_nil }
    end
  end
end
