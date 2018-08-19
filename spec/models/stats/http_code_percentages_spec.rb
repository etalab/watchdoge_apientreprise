require 'rails_helper'

describe Stats::HttpCodePercentages do
  subject(:code_percentages) { described_class.new(scope_duration: scope_duration, beginning_time: Time.zone.now) }

  describe 'only one add' do
    let(:scope_duration) { 3.hours }
    let(:endpoint) { Endpoint.where(api_name: 'apie').sample }
    let(:call) { CallResult.new(source) }

    before { code_percentages.add(call) }

    context 'when inside the scope' do
      let(:source) { fake_elk_source(endpoint, 2.hours.ago) }

      its(:http_code_counters) { is_expected.to eq(call.code.to_s => 1) }
      its(:number_of_calls) { is_expected.to eq(1) }
      its(:as_json) { is_expected.to match_json_schema('stats/http_code_percentages') }
    end

    context 'when outside the scope' do
      let(:source) { fake_elk_source(endpoint, 5.hours.ago) }

      its(:http_code_counters) { is_expected.to be_empty }
      its(:number_of_calls) { is_expected.to eq(0) }
      its(:as_json) { is_expected.to match_json_schema('stats/http_code_percentages') }

      it 'is not in scope' do
        # rubocop:disable RSpec/PredicateMatcher
        expect(code_percentages.in_scope?(5.hours.ago)).to be_falsey
        # rubocop:enable RSpec/PredicateMatcher
      end
    end
  end

  describe 'many adds are made' do
    before do
      sorted_fake_calls(size: 100, oldest_timestamp: oldest_timestamp).each do |e|
        code_percentages.add(e)
      end
    end

    context 'with many adds within the scope' do
      let(:scope_duration) { 15.minutes }
      let(:oldest_timestamp) { 14.minutes }

      its('http_code_counters.size') { is_expected.to be > 1 }
      its(:number_of_calls) { is_expected.to eq(100) }
      its(:as_json) { is_expected.to match_json_schema('stats/http_code_percentages') }
    end

    context 'with many adds and some outisde the scope' do
      let(:scope_duration) { 2.hours }
      let(:oldest_timestamp) { 3.hours }

      its(:number_of_calls) { is_expected.to be < 100 }
      its(:as_json) { is_expected.to match_json_schema('stats/http_code_percentages') }
    end
  end

  describe 'scope to words' do
    context 'when scope is 10 minutes' do
      let(:scope_duration) { 10.minutes }

      its(:as_json) { is_expected.to include_json(last_10_minutes: {}) }
    end

    context 'when scope is 30 hours' do
      let(:scope_duration) { 30.hours }

      its(:as_json) { is_expected.to include_json(last_30_hours: {}) }
    end

    context 'when scope is 8 days' do
      let(:scope_duration) { 8.days }

      its(:as_json) { is_expected.to include_json(last_8_days: {}) }
    end
  end

  context 'when making a dup / copy' do
    let(:scope_duration) { 2.hours }
    let(:endpoint) { Endpoint.where(api_name: 'apie').sample }
    let(:source) { fake_elk_source(endpoint, 1.hour.ago) }
    let(:call) { CallResult.new(source) }

    it 'makes a full copy' do
      code_percentages.add(call)
      copy = code_percentages.dup
      code_percentages.add(call)
      expect(code_percentages.number_of_calls).to eq(2)
      expect(copy.number_of_calls).to eq(1)
    end
  end
end
