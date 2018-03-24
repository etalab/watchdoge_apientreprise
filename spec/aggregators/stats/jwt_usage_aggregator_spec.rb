require 'rails_helper'

describe Stats::JwtUsageAggregator, vcr: { cassette_name: 'stats/jwt_usage'} do
  # rubocop:disable RSpec/InstanceVariable
  subject(:jwt_usage_aggregator) { @jwt_usage_aggregator }

  # rubocop:enable RSpec/InstanceVariable

  before do
    # CANT USE VCR WITHOUT MOCKING THE START DATE EVERYWHERE !!!!!
    allow(Time.zone).to receive(:now).and_return(Time.parse('2018-03-14 15:15:49 +0100'))

    remember_through_tests('jwt_usage_aggregator') do
      service = Stats::JwtUsageService.new(jti: valid_jti)
      service.send(:retrieve_all_jwt_usage)
      raw_data = service.send(:hits)
      described_class.new(raw_data: raw_data).tap(&:aggregate)
    end
  end

  # it does not mock the sub-aggregator... quite hard to do...
  its(:number_of_calls) { is_expected.to match_json_schema('stats/number_of_calls') }
  it 'has at least few calls in 8 days ' do
    expect(jwt_usage_aggregator.number_of_calls.dig(:number_of_calls, :last_8_days, :total)).to be > 2
  end

  its(:last_calls) { is_expected.to match_json_schema('stats/last_calls') }
  it 'has at least 20 last calls in the last 8 days' do
    expect(jwt_usage_aggregator.last_calls.dig(:last_calls).size).to be_between(20, Stats::LastCalls::LIMIT)
  end

  its(:http_code_percentages) { is_expected.to match_json_schema('stats/http_code_percentages') }
  it 'has at least few http code stats in 8 days ' do
    expect(jwt_usage_aggregator.http_code_percentages.dig(:http_code_percentages, :last_8_days).size).to be > 1
  end
end

