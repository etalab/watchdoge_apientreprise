require 'rails_helper'

describe ProviderAvailabilitiesController, type: :controller do
  describe '#index' do
    context 'when endpoint and period parameters are present', vcr: { cassette_name: 'stats/provider_availability_valid_call' } do
      subject { get :index, params: { endpoint: 'api/v2/cartes_professionnelles_fntp', period: '6M', format: :json } }

      before do
        Timecop.freeze(Time.new(2020, 9, 7))
      end

      after do
        Timecop.return
      end

      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to match_json_schema('stats/provider_availabilities') }
    end

    context 'when the endpoint parameter is not specified', vcr: { cassette_name: 'stats/provider_availability_invalid_endpoint' } do
      subject(:call!) { get :index, params: { period: '6M', format: :json } }

      its(:status) { is_expected.to eq(422) }

      it 'returns an error' do
        expected_body = { error: { message: 'No entry for endpoint ``' } }
        call!

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_body)
      end
    end

    context 'when the period parameter is not specified', vcr: { cassette_name: 'stats/provider_availability_invalid_period', record: :new_episodes } do
      subject(:call!) { get :index, params: { endpoint: 'api/v2/cartes_professionnelles_fntp', format: :json } }

      its(:status) { is_expected.to eq(422) }

      it 'returns an error' do
        expected_body = { error: { message: 'Invalid period format ``' } }
        call!

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_body)
      end
    end
  end
end
