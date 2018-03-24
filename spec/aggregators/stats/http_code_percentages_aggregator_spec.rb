require 'rails_helper'

describe Stats::HttpCodePercentagesAggregator do
  subject(:json) { code_percentage_aggregator.as_json }

  let(:code_percentage_aggregator) { described_class.new }

  describe 'with one element' do
    before { code_percentage_aggregator.aggregate(call) }

    let(:endpoint) { Endpoint.all.sample }
    let(:call) { CallCharacteristics.new(source) }

    context 'when it is in the first 30 hours' do
      let(:source) { fake_elk_source(endpoint, 5.hours.ago) }

      it { is_expected.to match_json_schema('stats/http_code_percentages') }

      it 'has last_30_hours json key' do
        expect(json.dig(:http_code_percentages, :last_30_hours)).not_to be_nil
        expect(json.dig(:http_code_percentages, :last_30_hours).size).to eq(1)
      end

      it 'has same last_8_days json key as 30_hours' do
        expect(json.dig(:http_code_percentages, :last_8_days)).to eq(json.dig(:http_code_percentages, :last_30_hours))
      end
    end

    context 'when it is in the first 8 days' do
      let(:source) { fake_elk_source(endpoint, 5.days.ago) }

      it { is_expected.to match_json_schema('stats/http_code_percentages') }

      it 'has not last_30_hours json key' do
        expect(json.dig(:http_code_percentages, :last_30_hours)).to include_json([])
      end

      it 'has last_8_days json key' do
        expect(json.dig(:http_code_percentages, :last_8_days)).not_to be_nil
        expect(json.dig(:http_code_percentages, :last_8_days).size).to eq(1)
      end
    end

    context 'when it is before 8 days' do
      let(:source) { fake_elk_source(endpoint, 10.days.ago) }

      it { is_expected.to match_json_schema('stats/http_code_percentages') }

      it 'has empty last_10_minutes json key' do
        expect(json.dig(:http_code_percentages, :last_10_minutes)).to include_json([])
      end

      it 'has empty last_30_hours json key' do
        expect(json.dig(:http_code_percentages, :last_30_hours)).to include_json([])
      end

      it 'has empty last_8_days json key' do
        expect(json.dig(:http_code_percentages, :last_8_days)).to include_json([])
      end
    end
  end


  describe 'when having multiple elements' do
    let(:endpoint) { Endpoint.all.sample }

    before do
      sorted_fake_calls(size: 100, oldest_timestamp: 9.minutes).each { |call| code_percentage_aggregator.aggregate(call) }
      sorted_fake_calls(size: 500, oldest_timestamp: 29.hours).each { |call| code_percentage_aggregator.aggregate(call) }
      sorted_fake_calls(size: 1000).each { |call| code_percentage_aggregator.aggregate(call) }
    end

    it { is_expected.to match_json_schema('stats/http_code_percentages') }

    it 'has the 3 time keys' do
      expect(json.dig(:http_code_percentages).keys.size).to eq(2)
      expect(json.dig(:http_code_percentages, :last_30_hours).size).to be > 0
      expect(json.dig(:http_code_percentages, :last_8_days).size).to be > 0
    end
  end
end
