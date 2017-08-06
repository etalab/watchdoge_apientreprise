require 'rails_helper'

describe PingV2Job, type: :job do
  subject { described_class.new }
  let(:endpoint_etablissements) do
    Endpoint.new(
      name: 'etablissements',
      api_version: 2,
      parameter: '41816609600069',
      options:
      {
        :recipient => 'SGMAP',
        :context => 'Ping'
      }
    )
  end

  it_behaves_like 'logstashable'

  it 'ensure all endpoints works', vcr: { cassette_name: 'apie_v2' } do
    expect(Rails.logger).not_to receive(:error)
    subject.perform
  end

  it 'ensure PingReaderWriter has a write method' do
    expect(Tools::PingReaderWriter.new).to respond_to(:write)
  end

  context 'happy path', vcr: { cassette_name: 'apie_v2' } do
    let(:filename) { described_class.send(:logfile) }

    before do
      allow_any_instance_of(described_class).to receive(:endpoints_v2).and_return([endpoint_etablissements])
      allow_any_instance_of(Tools::PingReaderWriter).to receive(:write)
      File.truncate(filename, 0) if File.exists?(filename)
    end

    it 'writes and log the new status' do
      expect(subject).to receive(:log)
      expect_any_instance_of(Tools::PingReaderWriter).to receive(:write).with(instance_of(PingStatus)) # write consistency is not tested here

      subject.perform
    end

    it 'log the correct data' do
      subject.perform

      last_line = File.readlines(filename).last
      json = JSON.parse(last_line)

      expect(DateTime.parse(json['date'])).to be_within(1.second).of DateTime.now
      expect(json).to include_json(
        msg: 'ping',
        endpoint: 'etablissements',
        status: 'up'
      )
    end
  end

  context 'invalid ping' do
    before do
      allow_any_instance_of(described_class).to receive(:endpoints_v2).and_return([endpoint_etablissements])
      allow_any_instance_of(PingStatus).to receive(:valid?).and_return(false)
      allow(subject).to receive(:get_service_status).and_return('down')
    end

    it 'should raise an error and don t log or write' do
      expect(Rails.logger).to receive(:error).with("Fail to write PingStatus(etablissements) it's invalid ({})")
      expect(subject).not_to receive(:log)
      expect_any_instance_of(Tools::PingReaderWriter).not_to receive(:write)
      subject.perform
    end
  end
end
