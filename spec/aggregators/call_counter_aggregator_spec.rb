require 'rails_helper'

describe CallCounterAggregator do
  subject(:json) { call_counter_aggregator.as_json }

  let(:call_counter_aggregator) { described_class.new }

  describe 'with one element' do
    before { call_counter_aggregator.aggregate(call) }

    let(:endpoint) { Endpoint.all.sample }
    let(:call) { CallCharacteristics.new(source) }

    context 'when it is in the first 10 minutes' do
      let(:source) { fake_elk_source(endpoint, 5.minutes.ago) }

      it { is_expected.to match_json_schema('stats/number_of_calls') }

      it 'has last_10_minutes json key' do
        expect(json.dig(:number_of_calls, :last_10_minutes)).not_to be_nil
        expect(json.dig(:number_of_calls, :last_10_minutes, :total)).to eq(1)
      end

      it 'has same last_30_hours json key as 10_minutes' do
        expect(json.dig(:number_of_calls, :last_30_hours)).to eq(json.dig(:number_of_calls, :last_10_minutes))
      end

      it 'has same last_8_days json key as 30_hours' do
        expect(json.dig(:number_of_calls, :last_8_days)).to eq(json.dig(:number_of_calls, :last_30_hours))
      end
    end

    context 'when it is in the first 30 hours' do
      let(:source) { fake_elk_source(endpoint, 5.hours.ago) }

      it { is_expected.to match_json_schema('stats/number_of_calls') }

      it 'has empty last_10_minutes json key' do
        expect(json.dig(:number_of_calls, :last_10_minutes)).to include_json(total: 0, by_endpoint: [])
      end

      it 'has last_30_hours json key' do
        expect(json.dig(:number_of_calls, :last_30_hours)).not_to be_nil
        expect(json.dig(:number_of_calls, :last_30_hours, :total)).to eq(1)
      end

      it 'has same last_8_days json key as 30_hours' do
        expect(json.dig(:number_of_calls, :last_8_days)).to eq(json.dig(:number_of_calls, :last_30_hours))
      end
    end

    context 'when it is in the first 8 days' do
      let(:source) { fake_elk_source(endpoint, 5.days.ago) }

      it { is_expected.to match_json_schema('stats/number_of_calls') }

      it 'has empty last_10_minutes json key' do
        expect(json.dig(:number_of_calls, :last_10_minutes)).to include_json(total: 0, by_endpoint: [])
      end

      it 'has empty last_30_hours json key' do
        expect(json.dig(:number_of_calls, :last_30_hours)).to include_json(total: 0, by_endpoint: [])
      end

      it 'has last_8_days json key' do
        expect(json.dig(:number_of_calls, :last_8_days)).not_to be_nil
        expect(json.dig(:number_of_calls, :last_8_days, :total)).to eq(1)
      end
    end

    context 'when it is before 8 days' do
      let(:source) { fake_elk_source(endpoint, 10.days.ago) }

      it { is_expected.to match_json_schema('stats/number_of_calls') }

      it 'has empty last_10_minutes json key' do
        expect(json.dig(:number_of_calls, :last_10_minutes)).to include_json(total: 0, by_endpoint: [])
      end

      it 'has empty last_30_hours json key' do
        expect(json.dig(:number_of_calls, :last_30_hours)).to include_json(total: 0, by_endpoint: [])
      end

      it 'has empty last_8_days json key' do
        expect(json.dig(:number_of_calls, :last_8_days)).to include_json(total: 0, by_endpoint: [])
      end
    end
  end


  describe 'when having multiple elements' do
    let(:endpoint) { Endpoint.all.sample }

    before do
      sorted_fake_calls(size: 100, oldest_timestamp: 9.minutes).each { |call| call_counter_aggregator.aggregate(call) }
      sorted_fake_calls(size: 500, oldest_timestamp: 29.hours).each { |call| call_counter_aggregator.aggregate(call) }
      sorted_fake_calls(size: 1000).each { |call| call_counter_aggregator.aggregate(call) }
    end

    it { is_expected.to match_json_schema('stats/number_of_calls') }

    it 'has the 3 time keys' do
      expect(json.dig(:number_of_calls).keys.size).to eq(3)
      expect(json.dig(:number_of_calls, :last_10_minutes, :total)).to be > 0
      expect(json.dig(:number_of_calls, :last_30_hours, :total)).to be > 0
      expect(json.dig(:number_of_calls, :last_8_days, :total)).to be > 0
    end
  end
end
