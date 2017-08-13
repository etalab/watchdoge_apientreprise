require 'rails_helper'

describe PingAPIEOnV2Job, type: :job do
  subject(:job) { described_class.new }

  let(:endpoint_etablissements) do
    Endpoint.new(
      name: 'etablissements',
      api_version: 2,
      api_name: 'apie',
      parameter: '41816609600069',
      options:
      {
        recipient: 'SGMAP',
        context: 'Ping'
      }
    )
  end

  it_behaves_like 'logstashable'

  it 'ensure all endpoints works', vcr: { cassette_name: 'apie_v2' } do
    expect(Rails.logger).not_to receive(:error)

    job.perform do |p|
      next if p.name == 'cotisations_msa' # TODO: what a big shit here /o/
      expect("#{p.name}: #{p.status}").to eq("#{p.name}: up")
    end
  end

  it 'ensure PingReaderWriter has a write method' do
    expect(Tools::PingReaderWriter.new).to respond_to(:write)
  end

  context 'happy path', vcr: { cassette_name: 'apie_v2' } do
    let(:filename) { described_class.send(:logfile) }
    let(:expected_json) do
      {
        msg: 'ping',
        endpoint: 'etablissements',
        status: 'up',
        api_version: 2,
        environment: 'test',
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:endpoints).and_return([endpoint_etablissements])
      allow_any_instance_of(Tools::PingReaderWriter).to receive(:write)
      allow_any_instance_of(HTTPResponseValidator).to receive(:valid?).and_return(true)
      File.truncate(filename, 0) if File.exist?(filename)
    end

    it 'writes and log the new status' do
      expect(job).to receive(:log)
      expect_any_instance_of(Tools::PingReaderWriter).to receive(:write).with(instance_of(PingStatus)) # write consistency is not tested here

      job.perform
    end

    it 'log the correct data' do
      job.perform

      last_line = File.readlines(filename).last
      json = JSON.parse(last_line)

      expect(DateTime.parse(json['date'])).to be_within(1.second).of DateTime.now
      expect(json).to include_json(expected_json)
    end
  end

  context 'invalid ping' do
    before do
      allow_any_instance_of(described_class).to receive(:endpoints).and_return([endpoint_etablissements])
      allow_any_instance_of(PingStatus).to receive(:valid?).and_return(false)
      allow(job).to receive(:get_http_response).and_return(nil)
      allow(job).to receive(:get_service_status).and_return('down')
    end

    it 'raises an error and don t log or write' do
      expect(Rails.logger).to receive(:error).with("Fail to write PingStatus(etablissements) it's invalid ({})")
      expect(job).not_to receive(:log)
      expect_any_instance_of(Tools::PingReaderWriter).not_to receive(:write)
      job.perform
    end
  end
end
