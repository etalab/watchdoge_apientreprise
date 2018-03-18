require 'rails_helper'

describe Stats::CallCounter do
  subject(:counter) { described_class.new(duration: duration, beginning_timestamp: beginning) }

  context 'with only one add' do
    let(:duration) { 3.hours }
    let(:beginning) { Time.zone.at(3.hours.ago) }

    before do
      fake_calls(size: 1, oldest_timestamp: duration).sort(&:timestamp).each do |e|
        counter.add(e)
      end
    end

    its(:total) { is_expected.to eq(1) }
    its('endpoints.size') { is_expected.to eq(1) }
    its(:as_json) { is_expected.to match_json_schema('call_counter') }
  end

  context 'with many adds' do
    let(:duration) { 14.minutes }
    let(:beginning) { 15.minutes.ago}

    before do
      fake_calls(size: 100, oldest_timestamp: duration).sort(&:timestamp).each do |e|
        counter.add(e)
      end
    end

    its(:total) { is_expected.to eq(100) }
    its('endpoints.size') { is_expected.to be_positive }
    its(:as_json) { is_expected.to match_json_schema('call_counter') }
  end
end