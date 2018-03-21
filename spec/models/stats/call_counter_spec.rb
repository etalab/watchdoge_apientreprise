require 'rails_helper'

describe Stats::CallCounter do
  subject(:counter) { described_class.new(duration: duration, beginning_time: Time.zone.now) }

  describe 'only one add' do
    let(:duration) { 3.hours }
    let(:endpoint) { Endpoint.all.sample }
    let(:call) { CallCharacteristics.new(source) }

    before { counter.add(call) }

    context 'when in the duration' do
      let(:source) { fake_elk_source(endpoint, 2.hours.ago) }

      its(:total) { is_expected.to eq(1) }
      its('endpoints.size') { is_expected.to eq(1) }
      its(:as_json) { is_expected.to match_json_schema('stats/call_counter') }
    end

    context 'when outside the duration' do
      let(:source) { fake_elk_source(endpoint, 5.hours.ago) }

      its(:total) { is_expected.to eq(0) }
      its('endpoints.size') { is_expected.to eq(0) }
      its(:as_json) { is_expected.to match_json_schema('stats/call_counter') }

      it 'is not in scope' do
        # rubocop:disable RSpec/PredicateMatcher
        expect(counter.in_scope?(5.hours.ago)).to be_falsey
      end
    end
  end

  describe 'many add are made' do
    before do
      sorted_fake_calls(size: 100, oldest_timestamp: oldest_timestamp).each do |e|
        counter.add(e)
      end
    end

    context 'with many adds within the duration' do
      let(:duration) { 15.minutes }
      let(:oldest_timestamp) { 14.minutes }

      its(:total) { is_expected.to eq(100) }
      its('endpoints.size') { is_expected.to be_positive }
      its(:as_json) { is_expected.to match_json_schema('stats/call_counter') }
    end

    context 'with many adds some outside the duration' do
      let(:duration) { 2.hours }
      let(:oldest_timestamp) { 3.minutes }

      its(:total) { is_expected.to be < 1000 }
      its('endpoints.size') { is_expected.to be_positive }
      its(:as_json) { is_expected.to match_json_schema('stats/call_counter') }
    end
  end

  describe 'duration to string' do
    context 'when duration is 10 minutes' do
      let(:duration) { 10.minutes }

      its(:as_json) { is_expected.to include_json(last_10_minutes: {}) }
    end

    context 'when duration is 30 hours' do
      let(:duration) { 30.hours }

      its(:as_json) { is_expected.to include_json(last_30_hours: {}) }
    end

    context 'when duration is 8 days' do
      let(:duration) { 8.days }

      its(:as_json) { is_expected.to include_json(last_8_days: {}) }
    end
  end

  context 'when making a dup / copy' do
    let(:duration) { 2.hours }
    let(:endpoint) { Endpoint.all.sample }
    let(:source) { fake_elk_source(endpoint, 1.hour.ago) }
    let(:call) { CallCharacteristics.new(source) }

    it 'makes a full copy' do
      counter.add(call)
      copy = counter.dup
      counter.add(call)
      expect(counter.total).to eq(2)
      expect(copy.total).to eq(1)
    end
  end
end