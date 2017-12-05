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

    its(:size) { is_expected.to equal(13) }

    describe 'providers' do
      let(:providers) { results.map { |r| r['provider_name'] }.sort }
      let(:expected_providers) { Tools::EndpointFactory.new('apie').providers_infos.keys.sort }

      it 'contains specifics providers' do
        expected_providers.delete('apie')
        expect(expected_providers).to eq(providers)
      end
    end

    # TODO: json-schema
    # rubocop:disable RSpec/ExampleLength
    # rubocop:disable RSpec/MultipleExpectations
    it 'contains availability history' do
      results.each do |provider|
        expect(provider['provider_name']).not_to be_empty

        provider['endpoints_history'].each do |ep|
          expect(ep['id']).to be_a(String)
          expect(ep['name']).to be_a(String)
          expect(ep['api_version']).to be_in([1, 2])
          expect(ep['sla']).to be_a(Float)
          expect(ep['sla'].to_s).to match(/^\d+\.\d+$/)
          expect(ep['sla']).to be > 45

          ep['availabilities'].each do |a|
            from = Time.parse(a[0])
            to = Time.parse(a[2])

            expect(a[0]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
            expect(a[2]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
            expect(to).to be >= from

            expect(a[1]).to be_in([0, 1])
          end
        end
      end
    end
  end
end
