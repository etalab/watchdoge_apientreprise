require 'rails_helper'

describe Stats::ApisUsageAggregator do
  subject(:json) { apis_usage_aggregator.as_json }

  let(:apis_usage_aggregator) { described_class.new }

  describe 'with one element' do
    before { apis_usage_aggregator.aggregate(call) }

    let(:endpoint) { Endpoint.where(api_name: 'apie').sample }
    let(:call) { CallResult.new(source) }

    context 'when it is in the first 30 hours' do
      let(:source) { fake_elk_source(endpoint, 5.hours.ago) }

      it { is_expected.to match_json_schema('stats/apis_usage') }

      it 'has last_30_hours json key' do
        expect(json.dig(:apis_usage, :last_30_hours, :by_endpoint)).not_to be_nil
        expect(json.dig(:apis_usage, :last_30_hours, :by_endpoint).size).to eq(1)
      end

      it 'has same last_8_days json key as 30_hours' do
        expect(json.dig(:apis_usage, :last_8_days)).to eq(json.dig(:apis_usage, :last_30_hours))
      end
    end

    context 'when it is in the first 8 days' do
      let(:source) { fake_elk_source(endpoint, 5.days.ago) }

      it { is_expected.to match_json_schema('stats/apis_usage') }

      it 'has not last_30_hours json key' do
        expect(json.dig(:apis_usage, :last_30_hours)).to include_json([])
      end

      it 'has last_8_days json key' do
        expect(json.dig(:apis_usage, :last_8_days, :by_endpoint)).not_to be_nil
        expect(json.dig(:apis_usage, :last_8_days, :by_endpoint).size).to eq(1)
      end
    end

    context 'when it is after 8 days' do
      let(:source) { fake_elk_source(endpoint, 10.days.ago) }

      it { is_expected.to match_json_schema('stats/apis_usage') }

      it 'has empty last_10_minutes json key' do
        expect(json.dig(:apis_usage, :last_10_minutes, :by_endpoint)).to include_json([])
      end

      it 'has empty last_30_hours json key' do
        expect(json.dig(:apis_usage, :last_30_hours, :by_endpoint)).to include_json([])
      end

      it 'has empty last_8_days json key' do
        expect(json.dig(:apis_usage, :last_8_days, :by_endpoint)).to include_json([])
      end
    end
  end

  describe 'when having multiple elements' do
    let(:endpoint) { Endpoint.where(api_name: 'apie').sample }

    before do
      sorted_fake_calls(size: 100, oldest_timestamp: 9.minutes).each { |call| apis_usage_aggregator.aggregate(call) }
      sorted_fake_calls(size: 500, oldest_timestamp: 29.hours).each { |call| apis_usage_aggregator.aggregate(call) }
      sorted_fake_calls(size: 1000).each { |call| apis_usage_aggregator.aggregate(call) }
    end

    it { is_expected.to match_json_schema('stats/apis_usage') }

    it 'has the 3 time keys' do
      expect(json.dig(:apis_usage).keys.size).to eq(3)
      expect(json.dig(:apis_usage, :last_10_minutes).size).to be > 0
      expect(json.dig(:apis_usage, :last_30_hours).size).to be > 0
      expect(json.dig(:apis_usage, :last_8_days).size).to be > 0
    end
  end
end
