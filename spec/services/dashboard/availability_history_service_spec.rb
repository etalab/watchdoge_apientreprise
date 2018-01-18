require 'rails_helper'

describe Dashboard::AvailabilityHistoryService, type: :service, vcr: { cassette_name: 'availability_history_shortened' } do
  let(:service) { @availability_results_perform }

  before do
    allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:query_name).and_return('availability_history_shortened')
    remember_through_tests('availability_results_perform') do
      described_class.new.perform
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
      let(:expected_providers) { Endpoint.all.map { |ep| ep.provider }.uniq.sort }

      it 'contains specifics providers' do
        expected_providers.delete('apientreprise')
        expected_providers.delete('sirene')
        expect(providers).to eq(expected_providers)
      end
    end

    it 'matches json-schema' do
      expect(json).to match_json_schema('availability_history')
    end

    it 'has no gap and from < to' do
      expect(results).to be_a_valid_availabilities_history
    end
  end

  describe 'invalid query', vcr: { cassette_name: 'invalid_query' } do
    subject { described_class.new.perform }

    before do
      allow_any_instance_of(described_class).to receive(:load_query).and_return({ query: { match_allllll: {} } }.to_json)
    end

    its(:success?) { is_expected.to be_falsey }
  end
end
