require 'rails_helper.rb'

describe PingMailer, type: :mailer do
  subject(:mail) { described_class.ping(ping_report) }

  let(:ping_report) { create(:ping_report, last_code: last_code) }

  context 'when situation has changed' do
    let(:last_code) { 200 }

    its(:to)      { is_expected.to eq([Rails.application.config_for(:secrets)['ping_email_recipient']]) }
    its(:from)    { is_expected.to eq(['ping.watchdoge@watchdoge.entreprise.api.gouv.fr']) }

    context 'when UP to DOWN' do
      let(:last_code) { 200 }

      before do
        ping_report.notify_new_ping(503, Time.now)
      end

      its(:subject) { is_expected.to match(/\[Watchdoge\] V2 etablissements successeurs DOWN à \d{2}h\d{2}/) }

      it 'body matches' do
        expect(mail.body.to_s.gsub(/\n/, '')).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+V2.+etablissements successeurs.+DOWN/)
      end

      it 'devilver the email' do
        expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'do not raise exception' do
        expect { mail.deliver_now }.not_to raise_error
      end
    end

    context 'when DOWN to UP' do
      let(:last_code) { 503 }

      before do
        ping_report.notify_new_ping(200, Time.now)
      end

      its(:subject) { is_expected.to match(/\[Watchdoge\] V2 etablissements successeurs UP à \d{2}h\d{2}/) }

      it 'body matches' do
        expect(mail.body.to_s.gsub(/\n/, '')).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+V2.+etablissements successeurs.+UP.+Il était DOWN depuis le \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
      end
    end

    it 'do not raise exception' do
      expect { mail.deliver_now }.not_to raise_error
    end

    it 'devilver the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context 'when report has not a sub_name' do
    let(:ping_report) { create(:ping_report, sub_name: nil) }

    its(:subject) { is_expected.to match(/\[Watchdoge\] V2 etablissements  UP/) }
  end
end
