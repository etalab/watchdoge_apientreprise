describe Tools::EndpointFactory do
  subject(:factory) { described_class.new(service) }

  let(:service) { 'apie' }

  context 'happy path' do
    let(:count) do
      hash = YAML.load_file(subject.send(:endpoint_config_file))
      hash['endpoints'].count + 2 # Etablissements predecesseur / successeur (yes not a perfect test...)
    end

    it 'return all the endpoints' do
      expect(Rails.logger).not_to receive(:error)

      endpoints = factory.load_all
      expect(endpoints.class).to be(Array)
      expect(endpoints.count).to eq(count)
      expect(endpoints.first.class).to be(Endpoint)
    end

    context 'create one endpoint' do
      subject { described_class.new(service).create('cotisations_msa', 2) }

      its(:name) { is_expected.to eq('cotisations_msa') }
      its(:api_version) { is_expected.to be 2 }
      its(:parameter) { is_expected.to eq('38069910800011') }
      its(:options) { is_expected.to include_json(recipient: 'SGMAP', context: 'Ping') }
      its(:valid?) { is_expected.to be_truthy }
    end
  end

  context 'invalid endpoint.yml file' do
    before do
      allow_any_instance_of(described_class).to receive(:endpoint_config_file).and_return('spec/support/payload_files/endpoints.yml')
    end

    it 'raises and error' do
      expect(Rails.logger).to receive(:error).with(/Fail to load endpoint from YAML: {.+} errors: {.*}/)
      factory.load_all
    end
  end
end
