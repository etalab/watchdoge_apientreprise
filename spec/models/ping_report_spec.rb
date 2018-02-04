require 'rails_helper'

describe PingReport, type: :model do
  let(:uname) { 'apie_2_etablissements' }

  describe 'report does not exists' do
    subject(:report) { described_class.find_or_create_by(uname: uname) }

    context 'when it does not exists yet, it saves DOWN' do
      before { report.notify_changes(503) }

      it { is_expected.not_to be_nil }
      its(:status) { is_expected.to eq('DOWN') }
      its(:last_code) { is_expected.to eq(503) }
      its(:first_downtime) { is_expected.to be_within(1.second).of Time.now }
      its(:changed?) { is_expected.to be_truthy }
    end

    context 'when it does not exists yet, it saves UP' do
      before { report.notify_changes(200) }

      it { is_expected.not_to be_nil }
      its(:status) { is_expected.to eq('UP') }
      its(:last_code) { is_expected.to eq(200) }
      its(:changed?) { is_expected.to be_truthy }
    end
  end

  describe 'report alreay exists' do
    subject(:report) { described_class.find_or_create_by(uname: uname) }

    before do
      create(:ping_report, last_code: last_code)
      report.notify_changes(new_code)
    end

    context 'when DOWN > UP' do
      let(:last_code) { 503 }
      let(:new_code) { 200 }

      it { is_expected.not_to be_nil }
      its(:status) { is_expected.to eq('UP') }
      its(:last_code) { is_expected.to eq(200) }
      its(:changed?) { is_expected.to be_truthy }
    end

    context 'when UP > DOWN' do
      let(:last_code) { 200 }
      let(:new_code) { 422 }

      it { is_expected.not_to be_nil }
      its(:status) { is_expected.to eq('DOWN') }
      its(:last_code) { is_expected.to eq(422) }
      its(:first_downtime) { is_expected.to be_within(1.second).of Time.now }
      its(:changed?) { is_expected.to be_truthy }
    end

    context 'when DOWN > DOWN' do
      let(:last_code) { 503 }
      let(:new_code) { 404 }

      it { is_expected.not_to be_nil }
      its(:status) { is_expected.to eq('DOWN') }
      its(:last_code) { is_expected.to eq(404) }
      its(:first_downtime) { is_expected.not_to be_within(1.second).of Time.now }
      its(:changed?) { is_expected.to be_falsy }
    end

    context 'when UP > UP' do
      let(:last_code) { 200 }
      let(:new_code) { 200 }

      it { is_expected.not_to be_nil }
      its(:status) { is_expected.to eq('UP') }
      its(:last_code) { is_expected.to eq(200) }
      its(:changed?) { is_expected.to be_falsy }
    end
  end

  # Begin ActiveRecord tests
  context 'when creating report with valid parameters' do
    subject(:report) { create(:ping_report) }

    its(:valid?) { is_expected.to be_truthy }

    it 'is in the database' do
      report.save
      expect(described_class.find_by(uname: uname)).not_to be_nil
    end
  end

  it 'fails to create a report with empty uname' do
    report = described_class.new
    expect(report).not_to be_valid
    expect(report.errors.messages[:uname]).not_to be_empty
  end

  describe 'find or create functionnality' do
    it 'creates a new report' do
      expect { described_class.find_or_create_by(uname: uname) }.to change { PingReport.all.count }.by(1)
    end

    context 'when it already exists' do
      before { create(:ping_report) }

      it 'do not increase report count' do
        # rubocop:disable Lint/AmbiguousBlockAssociation
        expect { described_class.find_or_create_by(uname: uname) }.not_to change { PingReport.all.count }
      end
    end
  end

  context 'when report is updated' do
    subject { described_class.find_by(uname: uname) }

    before do
      report = create(:ping_report)
      report.last_code = 400
      report.save
    end

    its(:last_code) { is_expected.to eq(400) }
  end

  context 'when report already exists' do
    subject(:report) { described_class.new(uname: uname) }

    before { create(:ping_report) }

    its(:valid?) { is_expected.to be_falsey }

    context 'with error messages' do
      subject { report.errors.messages }

      its([:uname]) { is_expected.not_to eq('has already been taken') }
    end
  end
  # End ActiveRecord tests
end
