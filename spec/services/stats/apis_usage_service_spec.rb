require 'rails_helper'

describe Stats::ApisUsageService, type: :service, vcr: { cassette_name: 'stats/apis_usage' } do
  subject(:service) { described_class.new(jti: valid_jti, elk_time_range: '30h').perform }

  describe 'e2e service' do
    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to match_json_schema('stats/apis_usage_item') }

    it 'has expected percentages' do
      expect(service.results[:by_endpoint].first[:percent_success]).to eq 97.6
      expect(service.results[:by_endpoint].first[:percent_not_found]).to eq 0.0
      expect(service.results[:by_endpoint].first[:percent_other_client_errors]).to eq 0.0
      expect(service.results[:by_endpoint].first[:percent_server_errors]).to eq 2.4
    end
  end
end
