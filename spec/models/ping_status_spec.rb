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
      json = JSON.parse(subject.to_json)

      expect(DateTime.parse(json['date'])).to be_within(1.second).of date
      expect(json).to include_json(
        name: name,
        api_version: api_version,
        status: status
      )
    end

    describe 'functionnalities' do
      let(:filename) { described_class.send(:status_file) }

      before do
        File.truncate(filename, 0) if File.exists?(filename)
      end

      context 'instanciating Ping from status.json file' do
        let(:service_name) { 'another service name' }
        subject { described_class.load_ping_status(service_name) }

        before do
          allow_any_instance_of(described_class).to receive(:status_file).and_return('spec/support/payload_files/status.json')
        end

        its(:name) { is_expected.to eq(service_name) }
        its(:api_version) { is_expected.to eq(2) }
        its(:date) { is_expected.to be_withn(1.second).of DateTime.parse('2017-07-21T16:46:25.609+02:00') }
        its(:status) { is_expected.to eq('up') }
      end

      context 'returning all status in json format' do
        subject { described_class.load_all_to_json }

        before do
          PingStatus.new({name: 'endpoint 1', api_version: 2, date: date, status: 'up'}).save
          PingStatus.new({name: 'endpoint 2', api_version: 2, date: date, status: 'down'}).save
          PingStatus.new({name: 'endpoint 3', api_version: 3, date: date, status: 'up'}).save
        end

        it 'is correctly loaded' do
          expect(DateTime.parse(subject['v2'][0]['date'])).to be_within(1.second).of date
          expect(DateTime.parse(subject['v2'][1]['date'])).to be_within(1.second).of date
          expect(DateTime.parse(subject['v3'][0]['date'])).to be_within(1.second).of date
          expect(subject).to include_json(
            environment: 'rspec',
            v2: [
              {
                name: 'endpoint 1',
                api_version: 2,
                status: 'up'
              },
              {
                name: 'endpoint 2',
                api_version: 2,
                status: 'down'
              }
            ],
            v3: [
              {
                name: 'endpoint 3',
                api_version: 3,
                status: 'up'
              }
            ]
          )
        end
      end

      it 'save to json file' do
        subject.save
        content = File.read(filename)
        json = JSON.parse(content)

        expect(DateTime.parse(json["v#{api_version}"][0]['date'])).to be_within(1.second).of date
        expect(json).to include_json(
          "v#{api_version}": [{
            name: name,
            api_version: api_version,
            status: status
          }]
        )
      end
    end
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
