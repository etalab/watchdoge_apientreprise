require 'rails_helper'

describe Stats::LastApiUsageService, type: :service, vcr: { cassette_name: 'stats/last_30_days_usage' } do
  subject(:service) { described_class.new.tap(&:perform) }

  describe 'service (e2e)' do
    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to eq(1_613_113) }
  end

  describe 'service (mocked)' do
    let(:last_30_days_usage) { JSON.parse(File.read('spec/support/payload_files/stats/last_30_days_usage.json')) }

    before do
      allow_any_instance_of(ElasticClient).to receive(:connected?).and_return(true)
      allow_any_instance_of(ElasticClient).to receive(:count)
      allow_any_instance_of(ElasticClient).to receive(:success?).and_return(true)
      allow_any_instance_of(described_class).to receive(:hits).and_return(last_30_days_usage)
    end

    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to eq(1_605_599) }
  end

  it_behaves_like 'elk invalid query'
end
