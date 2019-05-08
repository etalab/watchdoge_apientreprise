require 'rails_helper'

describe Stats::ApisUsageService, type: :service, vcr: { cassette_name: 'stats/apis_usage' } do
  subject(:service) { described_class.new(jti: valid_jti, elk_time_range: '30h').perform }

  describe 'e2e service' do
    its(:success?) { is_expected.to be_truthy }
    its(:results) { is_expected.to match_json_schema('stats/apis_usage_item') }
  end
end
