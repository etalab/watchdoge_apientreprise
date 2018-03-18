require 'rails_helper'

describe Aggregators::JwtUsageAggregator, vcr: { cassette_name: 'jwt_usage'} do
  # rubocop:disable RSpec/InstanceVariable
  subject(:jwt_usage_aggregator) { @jwt_usage_aggregator }

  # rubocop:enable RSpec/InstanceVariable

  before do
    remember_through_tests('jwt_usage_aggregator') do
      service = Stats::JwtUsageService.new(jti: valid_jti)
      service.send(:retrieve_all_jwt_usage)
      raw_data = service.send(:hits)
      described_class.new(raw_data: raw_data).aggregate
    end
  end

  its(:number_of_calls) { is_expected.to match_json_schema('number_of_calls') }
  its(:last_calls) { is_expected.to match_json_schema('last_calls') }
  its(:http_code_percentages) { is_expected.to match_json_schema('http_code_percentages') }
end

