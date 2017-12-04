require 'rails_helper.rb'

describe Tools::EndpointFactory do
  subject(:factory) { described_class.new(service) }

  let(:service) { 'apie' }

  context 'when happy path' do
    it 'return all the endpoints' do
      expect(Rails.logger).not_to receive(:error)

      # TODO: json-schema
      endpoints = factory.load_all
      expect(endpoints.class).to be(Array)
      expect(endpoints.count).to eq(endpoints_count)
      expect(endpoints.first.class).to be(Endpoint)

      providers = endpoints.map { |e| e.provider }.uniq
      expect(providers.size).to equal(providers_count)
    end

    context 'when create one endpoint' do
      subject { described_class.new(service).create('cotisations_msa', 2) }

      its(:name) { is_expected.to eq('cotisations_msa') }
      its(:api_version) { is_expected.to be 2 }
      its(:parameter) { is_expected.to eq('81104725700019') }
      its(:options) { is_expected.to include_json(recipient: 'SGMAP', context: 'Ping') }
      its(:valid?) { is_expected.to be_truthy }
    end

    context 'with provider list' do
      let(:expected_json) do
        {
          'name': 'insee',
          'endpoints_ids': [
            'entreprises__2',
            'etablissements__2',
            'entreprises_legacy__2',
            'etablissements_legacy__2',
            'entreprises__1',
            'etablissements__1',
            'etablissements_predecesseur_2',
            'etablissements_successeur_2'
          ]
        }
      end

      it 'has an entry for insee correctly formatted' do
        expect(subject.providers_infos['insee']).to include_json(expected_json)
      end
    end
  end

  context 'with invalid endpoint.yml file' do
    before do
      allow_any_instance_of(described_class).to receive(:endpoint_config_file).and_return('spec/support/payload_files/endpoints.yml')
    end

    it 'raises and error' do
      expect(Rails.logger).to receive(:error).with(/Fail to load endpoint from YAML: {.+} errors: {.*}/)
      factory.load_all
    end
  end
end
