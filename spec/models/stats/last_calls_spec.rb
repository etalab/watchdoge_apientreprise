require 'rails_helper'

describe Stats::LastCalls do
  subject(:json) { last_calls.as_json }

  let(:last_calls) { described_class.new }

  def random_call
    random_endpoint = Endpoint.where(api_name: 'apie').sample
    timestamp = 3.hours.ago
    source = fake_elk_source(random_endpoint, timestamp)
    CallResult.new(source)
  end

  describe 'without any call' do
    it { is_expected.to match_json_schema('stats/last_calls') }

    it 'has 0 element' do
      expect(json.dig(:last_calls).size).to eq(0)
    end
  end

  describe 'only one call' do
    before { last_calls.add random_call }

    it { is_expected.to match_json_schema('stats/last_calls') }

    it 'has 1 element' do
      expect(json.dig(:last_calls).size).to eq(1)
    end
  end

  describe 'with many calls' do
    before { number.times { last_calls.add random_call } }

    context 'when it is called less than 50 times' do
      let(:number) { 37 }

      it { is_expected.to match_json_schema('stats/last_calls') }

      it 'has 37 elements' do
        expect(json.dig(:last_calls).size).to eq(37)
      end
    end

    context 'when it is called more than 50 times' do
      let(:number) { 73 }

      it { is_expected.to match_json_schema('stats/last_calls') }

      it 'has 50 elements' do
        expect(json.dig(:last_calls).size).to eq(50)
      end
    end
  end
end
