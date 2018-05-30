require 'rails_helper'

describe Stats::JwtUsageService, type: :service, vcr: { cassette_name: 'non_regenerable/jwt_usage' } do
  subject(:service) { described_class.new(jti: JwtHelper.valid_jti).perform }

  describe 'e2e service' do
    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to match_json_schema('stats/jwt_usage') }
  end

  describe 'mocked data service' do
    let(:number_of_calls) { JSON.parse(File.read('spec/support/payload_files/stats/number_of_calls.json')) }
    let(:last_calls) { JSON.parse(File.read('spec/support/payload_files/stats/last_calls.json')) }
    let(:http_code_percentages) { JSON.parse(File.read('spec/support/payload_files/stats/http_code_percentages.json')) }

    before do
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:aggregate)
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:number_of_calls).and_return(number_of_calls)
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:last_calls).and_return(last_calls)
      allow_any_instance_of(Stats::JwtUsageAggregator).to receive(:http_code_percentages).and_return(http_code_percentages)
    end

    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to match_json_schema('stats/jwt_usage') }
  end

  it_behaves_like 'elk invalid query', jti: JwtHelper.valid_jti
end
