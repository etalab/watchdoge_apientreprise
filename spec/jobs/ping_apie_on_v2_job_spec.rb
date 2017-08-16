require 'rails_helper'

describe PingAPIEOnV2Job, type: :job do
  subject(:job) { described_class.new }

  let(:endpoint_etablissements) do
    Endpoint.new(
      name: 'etablissements',
      api_version: 2,
      api_name: 'apie',
      parameter: '41816609600069',
      options:
      {
        recipient: 'SGMAP',
        context: 'Ping'
      }
    )
  end

  it 'ensure all endpoints works', vcr: { cassette_name: 'apie_v2' } do
    expect(Rails.logger).not_to receive(:error)

    job.perform do |p|
      next if p.name == 'cotisations_msa' # TODO: what a big shit here /o/
      expect("#{p.name}: #{p.status}").to eq("#{p.name}: up")
    end
  end

  context 'happy path', vcr: { cassette_name: 'apie_v2' } do
    let(:expected_json) do
      {
        msg: 'ping',
        endpoint: 'etablissements',
        status: 'up',
        api_version: 2,
        environment: 'test',
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:endpoints).and_return([endpoint_etablissements])
    end

    it 'uses a custom endpoint url' do
      endpoint = Endpoints::EtablissementsPredecesseur.new
      expect(job).to receive(:request_url).and_return(endpoint.custom_url)

      job.perform_ping(endpoint)
    end
  end
end
