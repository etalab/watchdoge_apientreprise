require 'rails_helper.rb'

describe PingMailer, type: :mailer do
  subject(:mail) { described_class.ping(ping, endpoint) }

  let(:ping_name) { 'ping_name' }
  let(:endpoint) { Endpoint.new(name: ping_name, api_version: 2) }
  let(:ping) { PingStatus.new(name: ping_name, http_response: nil) }

  before do
    allow_any_instance_of(PingStatus).to receive(:status).and_return('up')
  end

  its(:subject) { is_expected.to match(/\[Watchdoge\] V\d \w+ (UP|DOWN|INCOMPLETE)/) }
  its(:to)      { is_expected.to eq([Rails.application.config_for(:secrets)['ping_email_recipient']]) }
  its(:from)    { is_expected.to eq(['ping.watchdoge@watchdoge.entreprise.api.gouv.fr']) }
  its(:body)    { is_expected.to match(/Le \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4}, le service V2 ping_name est UP/) }

  it 'do not raise exception' do
    expect { mail.deliver_now }.not_to raise_error
  end
end
