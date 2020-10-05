require 'rails_helper'

describe Stats::TauxDisposFournisseursService, type: :service do
  subject(:availability_service) { described_class.new(endpoint, period).perform }

  context 'when parameters are valid', vcr: { cassette_name: 'stats/provider_availability_valid_call' } do
    let(:endpoint) { 'api/v2/cartes_professionnelles_fntp' }
    let(:period) { '6M' }

    its(:success?) { is_expected.to eq(true) }

    # rubocop:disable RSpec/ExampleLength
    its(:endpoint_availability) do
      is_expected.to include(
        endpoint: 'api/v2/cartes_professionnelles_fntp',
        total_availability: Float,
        last_week_availability: Float,
        days_availability: all(include(
                                 a_string_matching(/\A\d{4}-\d{2}-\d{2}\z/),
                                 Hash
                               ))
      )
    end
    # rubocop:enable RSpec/ExampleLength

    describe 'availability computation' do
      # The mocked JSON has been created with the following data :
      # - 300 calls including 40 status 502 on he overal period
      # - 100 calls the last seven days including 10 status 502
      # Hence the expected ratios below
      let(:mocked_response) { JSON.parse(File.read('spec/support/payload_files/stats/provider_availability.json')) }

      before do
        Timecop.freeze(Date.new(2020, 10, 1))
        allow_any_instance_of(ElasticClient).to receive(:connected?).and_return(true)
        allow_any_instance_of(ElasticClient).to receive(:success?).and_return(true)
        allow_any_instance_of(ElasticClient).to receive(:raw_response).and_return(mocked_response)
      end

      after { Timecop.return }

      it 'computes the average availability on the period' do
        period_availability = availability_service.endpoint_availability[:total_availability]

        expect(period_availability).to eq(86.67)
      end

      it 'computes the average availability for the last week' do
        last_week_availability = availability_service.endpoint_availability[:last_week_availability]

        expect(last_week_availability).to eq(90.0)
      end
    end
  end

  context 'when "period" parameter is invalid', vcr: { cassette_name: 'stats/provider_availability_invalid_period' } do
    let(:endpoint) { 'api/v2/cartes_professionnelles_fntp' }
    let(:period) { 'weekly' }

    its(:success?) { is_expected.to eq(false) }

    its(:error) { is_expected.to eq(message: 'Invalid period format `weekly`') }
  end

  context 'when "endpoint" parameter is invalid', vcr: { cassette_name: 'stats/provider_availability_invalid_endpoint' } do
    let(:endpoint) { 'notanendpoint' }
    let(:period) { '6M' }

    its(:success?) { is_expected.to eq(false) }

    its(:error) { is_expected.to eq(message: 'No entry for endpoint `notanendpoint`') }
  end
end
