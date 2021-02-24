require 'rails_helper'

describe Dashboard::AvailabilityHistoryService, type: :service, vcr: { cassette_name: 'dashboard/availability_history_shortened' } do
  describe 'valid query' do
    # rubocop:disable RSpec/InstanceVariable
    let(:service) { @availability_results_perform }

    # rubocop:enable RSpec/InstanceVariable

    before do
      allow_any_instance_of(described_class).to receive(:query_name).and_return('availability_history_shortened')
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
      let(:providers) { results.map { |r| r['provider_name'] }.sort }
      let(:expected_providers) { Endpoint.all.map(&:provider).uniq.sort }

      its(:size) { is_expected.to equal(17) }

      it 'matches json-schema' do
        expect(json).to match_json_schema('dashboard/availability_history')
      end

      it 'has no gap and from < to' do
        expect(results).to be_a_valid_availabilities_history
      end
    end
  end

  it_behaves_like 'elk invalid query'
end
