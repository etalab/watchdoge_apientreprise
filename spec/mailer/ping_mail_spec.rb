describe PingMailer, type: :mailer do
  let(:ping_name) { 'ping_name' }
  let(:endpoint) { Endpoint.new(name: ping_name, api_version: 2) }
  let(:ping) { PingStatus.new(name: ping_name, http_response: nil) }

  subject(:mail) { described_class.ping(ping, endpoint) }

  before do
    allow_any_instance_of(PingStatus).to receive(:status).and_return('up')
  end

  it 'renders the headers' do
    expect(mail.subject).to match(/\[Watchdoge\] V\d \w+ (UP|DOWN|INCOMPLETE)/)
    expect(mail.to).to eq([Rails.application.config_for(:secrets)['ping_email_recipient']])
    expect(mail.from).to eq(['ping.watchdoge@watchdoge.entreprise.api.gouv.fr'])
  end

  it 'renders the body' do
    expect(mail.body).to match(/Le \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}, le service V2 ping_name est UP/)
  end

  it 'do not raise exception' do
    expect{ mail.deliver_now }.not_to raise_error
  end
end
