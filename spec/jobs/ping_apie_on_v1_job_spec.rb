require 'rails_helper'

describe PingAPIEOnV1Job, type: :job do
  subject(:job) { described_class.new }

  let(:endpoint_etablissements) do
    Endpoint.new(
      name: 'etablissements',
      api_version: 1,
      api_name: 'apie',
      parameter: '41816609600069',
      options:
      {
        recipient: 'SGMAP',
        context: 'Ping'
      }
    )
  end

  it 'ensure all endpoints works', vcr: { cassette_name: 'apie_v1' } do
    expect(Rails.logger).not_to receive(:error)

    job.perform do |p|
      next if p.name == 'msa/cotisations' # TODO: what a big shit here /o/
      expect("#{p.name}: #{p.status}").to eq("#{p.name}: up")
    end
  end

  context 'happy path', vcr: { cassette_name: 'apie_v1' } do
    let(:expected_json) do
      {
        msg: 'ping',
        endpoint: 'etablissements',
        status: 'up',
        api_version: 1,
        environment: 'test',
      }
    end
  end
end
