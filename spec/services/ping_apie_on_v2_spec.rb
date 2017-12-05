require 'rails_helper'

describe PingAPIEOnV2, type: :service do
  subject(:service) { described_class.new(hash) }

  let(:hash) { nil }
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

  # rubocop:disable RSpec/ExampleLength
  it 'ensure all endpoints works', vcr: { cassette_name: 'apie_v2' } do
    expect(Rails.logger).not_to receive(:error)

    service.perform do |p|
      next if %w[etablissements_legacy entreprises_legacy].include?(p.name) # TODO: re-run when it is up
      expect("#{p.name}: #{p.status}").to eq("#{p.name}: up")
      expect(p.url).not_to be_nil
    end

    pending('insee down')
  end

  describe 'send warning email if service down', vcr: { cassette_name: 'apie_v2' } do
    before do
      allow_any_instance_of(PingStatus).to receive(:status).and_return('down')
    end

    it 'asks to deliver an email' do
      delivery = double
      expect(delivery).to receive(:deliver_now).with(no_args)
      expect(PingMailer).to receive(:ping).and_return(delivery)
      service.perform_ping(endpoint_etablissements)
    end
  end

  describe 'with a specific period' do
    let(:hash) { { period: 5 } }

    it 'loads less endpoints' do
      expect(service.send(:endpoints).count).to eq(3)
    end
  end

  context 'happy path', vcr: { cassette_name: 'apie_v2' } do
    let(:expected_json) do
      {
        msg: 'ping',
        endpoint: 'etablissements',
        status: 'up',
        api_version: 2,
        environment: 'test'
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:endpoints).and_return([endpoint_etablissements])
    end

    it 'uses a custom endpoint url' do
      endpoint = Endpoints::EtablissementsPredecesseur.new
      expect(service).to receive(:endpoint_url).at_least(:once).and_return(endpoint.specific_url)

      service.perform_ping(endpoint)
    end
  end
end
