describe Tools::EndpointFactory do
    subject { described_class.new }

  context 'happy path' do
    let(:count) do
      hash = YAML.load_file(subject.send(:endpoint_config_file))
      hash['endpoints'].count
    end

    it 'return all the endpoints' do
      expect(Rails.logger).not_to receive(:error)

      endpoints = subject.load_all
      expect(endpoints.class).to be(Array)
      expect(endpoints.count).to eq(count)
      expect(endpoints.first.class).to be(Endpoint)
    end
  end

  context 'invalid endpoint.yml file' do
    before do
      allow_any_instance_of(described_class).to receive(:endpoint_config_file).and_return('spec/support/payload_files/endpoints.yml')
    end

    it 'should raise and error' do
      expect(Rails.logger).to receive(:error).with(/Fail to load endpoint from YAML: {.+} errors: {.*}/)
      subject.load_all
    end
  end
end
