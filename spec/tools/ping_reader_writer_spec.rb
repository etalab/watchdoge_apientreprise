describe Tools::PingReaderWriter do
  let(:service_name) { 'service name' }
  let(:api_version) { 2 }
  let(:date) { DateTime.now }
  let(:status) { 'down' }
  let(:environment) { 'test' }
  let(:ping_status) do
    PingStatus.new(
      name: service_name,
      api_version: api_version,
      date: date,
      status: status,
      environment: environment
    )
  end

  describe 'load: object creation of a PingStatus from name' do
    subject(:ping) { described_class.new.load(service_name, api_version) }

    before do
      allow_any_instance_of(described_class).to receive(:status_file).and_return('spec/support/payload_files/status.json')
    end

    describe 'service exists' do
      its(:name) { is_expected.to eq(service_name) }
      its(:api_version) { is_expected.to eq(2) }
      its(:status) { is_expected.to eq('up') }
      its(:environment) { is_expected.to eq('test') }

      it 'is the correct date' do
        expect(DateTime.parse(ping.date)).to be_within(1.second).of DateTime.parse('2017-07-21T16:46:25.609+02:00')
      end
    end

    describe 'service doesn t exists' do
      let(:service_name) { 'not a service' }

      it 'is not a version 3' do
        ping = described_class.new.load(service_name, 3)
        expect(ping).to be_nil
      end

      it 'have not version 42' do
        ping = described_class.new.load(service_name, 42)
        expect(ping).to be_nil
      end
    end
  end

  describe 'saving' do
    let(:filename) { described_class.new.send(:status_file) }
    let(:expected_json) do
      {
        "v#{api_version}": [{
          name: service_name,
          api_version: api_version,
          status: status,
          environment: environment
        }]
      }
    end

    let(:expected_updated_json) do
      {
        "v#{api_version}": [{
          status: 'up'
        }]
      }
    end

    before do
      File.truncate(filename, 0) if File.exist?(filename)
      described_class.new.write(ping_status)
    end

    it 'writes a new ping in json' do
      content = File.read(filename)
      json = JSON.parse(content)

      expect(DateTime.parse(json["v#{api_version}"][0]['date'])).to be_within(1.second).of date
      expect(json).to include_json(expected_json)
    end

    it 'writes an existing ping in json' do
      ping_status.status = 'up'
      described_class.new.write(ping_status)

      json = JSON.parse(File.read(filename))

      expect(json).to include_json(expected_updated_json)
    end
  end

  context 'returning all status in json format' do
    subject(:pings_hash) { described_class.new.load_all_to_json }

    let(:date) { DateTime.parse('2017-07-21T16:46:25.609+02:00') }
    let(:expected_json) do
      {
        environment: 'test',
        v2: [
          {
            name: 'service name',
            api_version: 2,
            status: 'up',
            environment: 'test'
          },
          {
            name: 'another service name',
            api_version: 2,
            status: 'down',
            environment: 'test'
          }
        ],
        v3: [
          {
            name: 'service name',
            api_version: 3,
            status: 'down',
            environment: 'test'
          }
        ]
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:status_file).and_return('spec/support/payload_files/status.json')
    end

    it 'is correctly loaded' do
      expect(pings_hash.class).to be(Hash)
      expect(DateTime.parse(pings_hash[:v2][0][:date])).to be_within(1.second).of date
      expect(DateTime.parse(pings_hash[:v2][1][:date])).to be_within(1.second).of date
      expect(DateTime.parse(pings_hash[:v3][0][:date])).to be_within(1.second).of date
      expect(pings_hash).to include_json(expected_json)
    end
  end
end
