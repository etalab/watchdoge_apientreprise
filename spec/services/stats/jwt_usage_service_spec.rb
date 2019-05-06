require 'rails_helper'

describe Stats::JwtUsageService, type: :service, vcr: { cassette_name: 'stats/jwt_usage' } do
  subject(:service) { described_class.new(jti: valid_jti).perform }

  describe 'e2e service' do
    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to match_json_schema('stats/jwt_usage') }
  end

  describe 'mocked data service' do
    let(:last_calls) { JSON.parse(File.read('spec/support/payload_files/stats/last_calls.json')) }
    let(:apis_usage) { JSON.parse(File.read('spec/support/payload_files/stats/apis_usage.json')) }

    before do
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:aggregate)
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:last_calls).and_return(last_calls)
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:apis_usage).and_return(apis_usage)
    end

    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to match_json_schema('stats/jwt_usage') }
  end

  it_behaves_like 'elk invalid query', jti: valid_jti
end
