require 'rails_helper'

describe Stats::CallCounter do
  subject(:counter) { described_class.new(duration: 15.minutes, beginning_timestamp: Time.zone.at(3.hours.ago)) }

  context 'with only one add' do
    before do
      fake_calls(size: 1) do |e|
        counter.add(e)
      end
    end

    its(:total) { is_expected.to eq(1) }
    its('endpoints.size') { is_expected.to eq(1) }
    its(:as_json) { is_expected.to match_json_schema('call_counter') }
  end

  context 'with many adds' do
    before do
      fake_calls(size: 100) do |e|
        counter.add(e)
      end
    end

    its(:total) { is_expected.to eq(100) }
    its('endpoints.size') { is_expected.to be_positive }
    its(:as_json) { is_expected.to match_json_schema('call_counter') }
  end
end