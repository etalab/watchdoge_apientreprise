require 'rails_helper'

describe PingMailer, type: :mailer do
  subject(:mail) { described_class.ping(endpoint, ping_report) }

  let(:endpoint) { create(:endpoint) }
  let(:ping_report) { create(:ping_report, uname: 'apie_2_certificats_test', last_code: last_code) }

  context 'when situation has changed' do
    let(:last_code) { 200 }
    let(:new_code) { 200 }

    before { ping_report.notify_change(new_code) }

    its(:to)      { is_expected.to eq([Rails.application.config_for(:secrets)['ping_email_recipient']]) }
    its(:from)    { is_expected.to eq(['test@example.com']) }

    context 'when UP to DOWN' do
      let(:last_code) { 200 }
      let(:new_code) { 503 }

      its(:subject) { is_expected.to match(/\[Watchdoge\] V2 Certificats Test DOWN à\s+\d{1,2}h\d{1,2}/) }

      it 'body matches' do
        expect(mail.body.to_s.delete("\n")).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+V2.+Certificats Test.+DOWN/)
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
      let(:new_code) { 200 }

      its(:subject) { is_expected.to match(/\[Watchdoge\] V2 Certificats Test UP à\s+\d{1,2}h\d{1,2}/) }

      it 'body matches' do
        expect(mail.body.to_s.delete("\n")).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+V2.+Certificats Test.+UP.+Il était DOWN depuis le \d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
      end
    end

    it 'do not raise exception' do
      expect { mail.deliver_now }.not_to raise_error
    end

    it 'devilver the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
