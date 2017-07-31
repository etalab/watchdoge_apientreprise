require 'rails_helper'

describe PingV2Job, type: :job do
  subject { described_class.new }

  it_behaves_like 'logstashable'

  context 'happy path', vcr: { cassette_name: 'apie_v2' } do
    let(:filename) { described_class.send(:logfile) }

    before do
      allow_any_instance_of(described_class).to receive(:service_names).and_return(%w(insee_etablissement))
      File.truncate(filename, 0) if File.exists?(filename)
    end

    it 'saves and log the new status' do
      expect(subject).to receive(:log)
      expect_any_instance_of(PingStatus).to receive(:save)

      subject.perform
    end

    it 'log the correct data' do
      subject.perform

      last_line = File.readlines(filename).last
      json = JSON.parse(last_line)

      expect(DateTime.parse(json['date'])).to be_within(1.second).of DateTime.now
      expect(json).to include_json(
        msg: 'ping',
        endpoint: 'insee_etablissement',
        status: 'up'
      )
    end
  end
end
