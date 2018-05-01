require 'rails_helper'
require 'sidekiq/testing'

describe PingWorker, type: :worker do
  let(:uname) { 'apie_2_certificats_qualibat' }

  before { create(:endpoint) }

  it 'fails to run the job' do
    described_class.perform_async(uname: uname) # wrong way to call the task
    expect { described_class.drain }.to raise_error(TypeError)
  end

  it 'successfully run the job', vcr: { cassette_name: 'apie/v2_qualibat' } do
    described_class.perform_async(uname) # correct way to call the task
    expect { described_class.drain }.not_to raise_error
  end

  it 'enqueue a job' do
    expect { described_class.perform_async(uname) }.to change { described_class.jobs.size }.by(1)
  end

  it 'calls apie_2_certificats_qualibat', vcr: { cassette_name: 'apie/v2_qualibat' } do
    expect_any_instance_of(Endpoint).to receive(:http_response).exactly(:once).and_call_original
    described_class.new.perform(uname)
  end

  describe 'email functionnality' do
    let(:up_response) { Net::HTTPResponse.new(1.0, 200, 'OK') }
    let(:down_response) { Net::HTTPResponse.new(1.0, 404, 'KO') }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before { create(:ping_report, uname: 'apie_2_certificats_qualibat', last_code: last_code) }

    context 'when UP > ??' do
      let(:last_code) { 200 }

      it 'is going DOWN' do
        allow_any_instance_of(Endpoint).to receive(:http_response).and_return(down_response)
        expect(PingMailer).to receive(:ping).exactly(:once).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        described_class.new.perform(uname)
      end

      it 'is still UP' do
        allow_any_instance_of(Endpoint).to receive(:http_response).and_return(up_response)
        expect(PingMailer).not_to receive(:ping)
        expect(message_delivery).not_to receive(:deliver_later)
        described_class.new.perform(uname)
      end
    end

    context 'when DOWN > ??' do
      let(:last_code) { 404 }

      it 'is still DOWN' do
        allow_any_instance_of(Endpoint).to receive(:http_response).and_return(down_response)
        expect(PingMailer).not_to receive(:ping)
        expect(message_delivery).not_to receive(:deliver_later)
        described_class.new.perform(uname)
      end

      it 'is going UP' do
        allow_any_instance_of(Endpoint).to receive(:http_response).and_return(up_response)
        expect(PingMailer).to receive(:ping).exactly(:once).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        described_class.new.perform(uname)
      end
    end
  end

  context 'when it is an API v1' do
    let(:uname) { 'apie_1_fake_api' }

    before do
      create(:endpoint, uname: uname, api_version: 1)
      allow_any_instance_of(Endpoint).to receive(:http_response).and_return(Net::HTTPResponse.new(1.0, 200, 'OK'))
    end

    it 'do not send an email' do
      expect(PingMailer).not_to receive(:ping)
      described_class.perform_async(uname)
    end
  end
end
