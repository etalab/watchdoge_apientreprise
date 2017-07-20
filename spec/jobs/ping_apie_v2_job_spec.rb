require 'rails_helper'

describe PingAPIEV2Job, type: :job do
  subject { described_class.new }

  context 'happy path', vcr: { cassette_name: 'apie_v2' } do
    it_behaves_like 'logstashed_ping'

    it 'updates APIE status with new ping status' do
      subject.perform
    end
  end
end
