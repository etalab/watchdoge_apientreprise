require 'rails_helper.rb'

describe PingReport, type: :model do
  describe 'load from database or create' do
    it 'aleady exists in database' do
      create(:ping_report)
      expect { described_class.get_latest_where(name: 'etablissements', sub_name: 'successeurs', api_version: 2) }.not_to change { PingReport.count }
    end

    it 'do not alreay exists in database' do
      expect { described_class.get_latest_where(name: 'etablissements', sub_name: 'successeurs', api_version: 2) }.to change { PingReport.count }
    end

    context 'first report generate with code 200' do
      subject { PingReport.find_by(name: 'etablissements', sub_name: 'successeurs', api_version: 2) }

      before do
        described_class.get_latest_where(name: 'etablissements', sub_name: 'successeurs', api_version: 2)
      end

      its(:last_code) { is_expected.to eq(200) }
    end
  end

  describe 'when notify new ping' do
    subject(:report) { described_class.get_latest_where(name: 'etablissements', sub_name: 'successeurs', api_version: 2) }
    let(:now) { Time.now }

    context 'when it does not exists yet' do
      before do
        report.notify_new_ping(503, now)
      end

      it 'saves when DOWN' do
        new_report = described_class.find_by(name: 'etablissements', sub_name: 'successeurs', api_version: 2)
        expect(new_report).not_to be_nil
        expect(new_report.last_code).to eq(503)
      end
    end

    context 'when it does not exists yet' do
      before do
        report.notify_new_ping(200, now)
      end

      it 'saves when UP' do
        new_report = described_class.find_by(name: 'etablissements', sub_name: 'successeurs', api_version: 2)
        expect(new_report).not_to be_nil
        expect(new_report.last_code).to eq(200)
      end
    end

    describe 'saving in database when has_changed' do
      it 'exists and saves when DOWN > UP' do
        create(:ping_report, last_code: 503)
        expect(report).to receive(:save).and_return(true)
        report.notify_new_ping(200, now)
        expect(described_class.find_by(name: 'etablissements', sub_name: 'successeurs', api_version: 2)).not_to be_nil
      end
    end

    context 'when the service UP > DOWN' do
      before do
        create(:ping_report, last_code: 200)
        subject.notify_new_ping(503, now)
      end

      its(:status) { is_expected.to eq('DOWN') }
      its(:has_changed?) { is_expected.to be_truthy }
      its(:first_downtime) { is_expected.to eq(now) }
    end

    context 'when the service is DOWN > DOWN' do
      before do
        create(:ping_report, last_code: 404)
        subject.notify_new_ping(503, now)
      end

      its(:status) { is_expected.to eq('DOWN') }
      its(:has_changed?) { is_expected.to be_falsy }
      its(:first_downtime) { is_expected.not_to eq(now) }
    end

    context 'when the service is DOWN > UP' do
      before do
        create(:ping_report, last_code: 404)
        subject.notify_new_ping(200, now)
      end

      its(:status) { is_expected.to eq('UP') }
      its(:has_changed?) { is_expected.to be_truthy }
    end

    context 'when the service is UP > UP' do
      before do
        create(:ping_report, last_code: 200)
        subject.notify_new_ping(200, now)
      end

      its(:status) { is_expected.to eq('UP') }
      its(:has_changed?) { is_expected.to be_falsey }
    end
  end

  context 'when it is created' do
    subject(:report) { create(:ping_report) }

    it 'is valid' do
      is_expected.to be_valid
    end

    it 'is in the database' do
      subject.save
      expect(described_class.find_by(name: report.name, sub_name: report.sub_name, api_version: report.api_version)).not_to be_nil
    end
  end

  context 'when it is updated' do
    subject { described_class.find_by(name: report.name, sub_name: report.sub_name, api_version: report.api_version) }

    let(:report) { build(:ping_report) }

    before do
      report = create(:ping_report)
      report.save
      report.last_code = 400
      report.save
    end

    its(:last_code) { is_expected.to eq(400) }
  end

  describe 'when it has errors' do
    subject(:report) { described_class.create(hash) }

    context 'empty hash' do
      let(:hash) { {} }

      before do
        report.save
      end

      its(:valid?) { is_expected.to be_falsey }

      context 'with error messages' do
        subject { report.errors.messages }

        its([:name]) { is_expected.not_to be_empty }
        its([:api_version]) { is_expected.not_to be_empty }
      end
    end

    context 'already existing report' do
      let(:hash) { { name: 'etablissements', sub_name: 'successeurs', api_version: 2 } }

      before do
        create(:ping_report)
      end

      its(:valid?) { is_expected.to be_falsey }

      context 'with error messages' do
        subject { report.errors.messages }

        its([:name]) { is_expected.not_to eq('has already been taken') }
      end
    end
  end
end
