require 'rails_helper'

describe Dashboard::AvailabilityHistoryElastic, type: :service, vcr: { cassette_name: 'availability_history' } do
  let(:service) { @availability_results_get }

  before do
    remember_through_tests('availability_results_get') do
      described_class.new.get
    end
  end

  describe 'service' do
    subject { service }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results' do
    subject(:results) { service.results }

    let(:json) { { results: results } }

    its(:size) { is_expected.to equal(13) }

    describe 'providers' do
      let(:providers) { results.map { |r| r['provider_name'] }.sort }
      let(:expected_providers) { Tools::EndpointFactory.new('apie').providers_infos.keys.sort }

      it 'contains specifics providers' do
        expected_providers.delete('apie')
        expect(expected_providers).to eq(providers)
      end
    end

    it 'matches json-schema' do
      expect(json).to match_json_schema('availability_history')
    end

    # rubocop:disable RSpec/ExampleLength
    it 'has no gap and from < to' do
      results.each do |provider|
        provider['endpoints_history'].each do |ep|
          max_index = ep['availability_history'].size - 1
          index = 0
          previous_to_time = nil
          ep['availability_history'].each do |avail|
            if index < max_index
              # from < to (except for last one)
              expect(Time.parse(avail[0])).to be < Time.parse(avail[2])
              index += 1
            end

            # has no gap
            unless previous_to_time.nil?
              from_time = Time.parse(avail[0])
              expect(from_time).to eq(previous_to_time)
            end

            previous_to_time = Time.parse(avail[2])
          end
        end
      end
    end
  end

  describe 'invalid query', vcr: { cassette_name: 'invalid_query' } do
    subject { described_class.new.get }

    before do
      allow_any_instance_of(described_class).to receive(:load_query).and_return({ query: { match_allllll: {} } }.to_json)
    end

    its(:success?) { is_expected.to be_falsey }
  end
end
