require 'rails_helper'

describe Stats::NumberOfCalls do
  subject(:nb_calls) { described_class.new }

  let(:filename) { 'spec/support/payload_files/elk_sources/jwt_usage.json' }
  let(:source_example) { JSON.parse(File.read(filename)) }
  let(:endpoint_ping_result) { CallCharacteristics.new(source_example) }

  describe 'one element' do
    before { nb_calls.aggregate(endpoint_ping_result) }

    its(:to_json) { is_expected.to match_json_schema('number_of_calls') }
  end

  describe 'when having multiple elements' do
    before do
      fake_calls(size: 200) do |endpoint_ping_result|
        nb_calls.aggregate(endpoint_ping_result)
      end
    end

    its(:to_json) { is_expected.to match_json_schema('number_of_calls') }
  end
end