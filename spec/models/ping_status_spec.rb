describe PingStatus, type: :model do
  context 'happy path' do
    let(:name) { 'service name' }
    let(:api_version) { 2 }
    let(:date) { DateTime.now }
    let(:status) { 'up' }

    subject { described_class.new(name: name, api_version: api_version, date: date, status: status) }

    its(:name) { is_expected.to eq(name) }
    its(:api_version) { is_expected.to eq(api_version) }
    its(:date) { is_expected.to eq(date) }
    its(:status) { is_expected.to eq(status) }
    its(:valid?) { is_expected.to be_truthy }

    it 'print to json' do
      json_string = subject.to_json
      expect(json_string.class).to be(String)

      json = JSON.parse(json_string)
      expect(DateTime.parse(json['date'])).to be_within(1.second).of date
      expect(json).to include_json(
        name: name,
        api_version: api_version,
        status: status
      )
    end

    it 'export as json' do
      json = subject.as_json

      expect(json.class).to be(Hash)
      expect(DateTime.parse(json['date'])).to be_within(1.second).of date
      expect(json).to include_json(
        name: name,
        api_version: api_version,
        status: status
      )
    end

    context 'is not valid' do
      describe 'invalid data' do
        subject { described_class.new({api_version: 5, date: 'not a date', status: 'not a status'}) }

        it 'contains specifics errors' do
          expect(subject.valid?).to be_falsy
          json = subject.errors.messages
          expect(json[:name]).not_to        be_nil
          expect(json[:api_version]).not_to be_nil
          expect(json[:date]).not_to        be_nil
          expect(json[:status]).not_to        be_nil
        end
      end

      describe 'nil data' do
        subject { described_class.new({name: 'valid name'}) }

        it 'contains specifics errors' do
          expect(subject.valid?).to be_falsy
          json = subject.errors.messages
          expect(json[:name]).to            be_empty
          expect(json[:api_version]).not_to be_nil
          expect(json[:date]).not_to        be_nil
          expect(json[:code]).not_to        be_nil
        end
      end
    end
  end
end
