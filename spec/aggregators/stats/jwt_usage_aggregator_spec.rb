require 'rails_helper'

describe Stats::JwtUsageAggregator do
  context 'with unknown data' do
    subject(:agg) { described_class.new(raw_data: raw_data) }

    let(:unknown_data) { JSON.parse(File.read('spec/support/payload_files/unknown_elasticsearch_raw_data.json')) }
    let(:raw_data) { [unknown_data] }

    before { agg.aggregate }

    it 'has empty number of calls' do
      expect(agg.number_of_calls.dig(:number_of_calls, :last_10_minutes, :total)).to eq 0
    end

    it 'has empty last_calls' do
      expect(agg.last_calls.dig(:last_calls)).to be_empty
    end

    it 'has empty code percentages' do
      expect(agg.http_code_percentages.dig(:http_code_percentages, :last_30_hours)).to be_empty
    end
  end

  context 'with valid data', vcr: { cassette_name: 'stats/jwt_usage' } do
    # rubocop:disable RSpec/InstanceVariable
    subject(:jwt_usage_aggregator) { @jwt_usage_aggregator }

    # rubocop:enable RSpec/InstanceVariable

    before do
      stub_jwt_usage_request
      # CANT USE VCR WITHOUT MOCKING THE START DATE EVERYWHERE !!!!!
      allow(Time.zone).to receive(:now).and_return(Time.zone.parse('2018-03-14 15:15:49 +0100'))

      remember_through_tests('jwt_usage_aggregator') do
        service = Stats::JwtUsageService.new(jti: JwtHelper.valid_jti)
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
end
