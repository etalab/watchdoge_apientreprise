require 'rails_helper'

describe Endpoint, type: :model do
  describe 'class methods' do
    before { Tools::EndpointDatabaseFiller.instance.refill_database }

    it 'finds Endpoint with perfect url' do
      expect(described_class.find_by_ping_url('/v2/cotisations_msa/81104725700019').uname).to eq('apie_2_cotisations_msa')
    end

    it 'finds Endpoint with wrong parameter' do
      expect(described_class.find_by_ping_url('v2/liasses_fiscales_dgfip/2016/declarations/811047257').uname).to eq('apie_2_liasses_fiscales_dgfip_declaration')
    end

    it 'finds Doc Asso Endpoint with wrong parameter' do
      expect(described_class.find_by_ping_url('/v2/documents_associations/W262001597').uname).to eq('apie_2_documents_associations_rna')
    end

    it 'finds Endpoint without parameter' do
      expect(described_class.find_by_ping_url('/v2/liasses_fiscales_dgfip/2013/dictionnaire').uname).to eq('apie_2_liasses_fiscales_dgfip_dictionnaire')
    end

    it 'logs an error when not found' do
      expect(Rails.logger).to receive(:error)
      described_class.find_by_ping_url('v2/plop/wrong/url')
    end
  end

  # Begin: real testing
  context 'with one redirection' do
    let(:uname) { 'apie_2_homepage' }

    before { create(:endpoint, uname: uname, provider: 'apientreprise', ping_url: '/') }

    it 'follows redirection once', vcr: { cassette_name: 'apie/v2_homepage' } do
      expect_any_instance_of(described_class).to receive(:fetch_with_redirection).exactly(:twice).and_call_original
      described_class.find_by(uname: uname).http_response
    end
  end

  describe 'all endpoints must be valids' do
    before { Tools::EndpointDatabaseFiller.instance.refill_database }

    it 'return 200 for all endpoints', vcr: { cassette_name: 'apie_all' } do
      Endpoint.all.each do |ep|
        response = described_class.find_by(uname: ep.uname).http_response
        expect(response).to be_a(Net::HTTPResponse)
        expect(response.code).to eq('200')
      end
    end

    it 'return 200: qualibat v2', vcr: { cassette_name: 'apie/v2_qualibat' } do
      response = described_class.find_by(uname: 'apie_2_certificats_qualibat').http_response
      expect(response).to be_a(Net::HTTPResponse)
      expect(response.code).to eq('200')
    end
  end
  # End: real testing

  describe 'url is always good' do
    it 'is an apie v1 endpoint' do
      ep = Endpoint.new(api_name: 'apie', api_version: 1, ping_url: '/v1/toto/SIREN')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/apientreprise.fr/)
      expect(ep.uri.path).to eq('/v1/toto/SIREN')
      expect(ep.uri.query).to match(/token=.+/)
    end

    it 'is an apie v2 endpoint' do
      ep = Endpoint.new(api_name: 'apie', api_version: 2, ping_url: '/v2/toto/SIREN')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/entreprise.api.gouv.fr/)
      expect(ep.uri.path).to eq('/v2/toto/SIREN')
      expect(ep.uri.query).to match(/token=.+/)
    end

    it 'is an apie v2 endpoint with options' do
      ep = Endpoint.new(api_name: 'apie', api_version: 2, ping_url: '/v2/toto/SIREN', json_options: '{"opt": "plop", "opt2": "test"}')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/entreprise.api.gouv.fr/)
      expect(ep.uri.path).to eq('/v2/toto/SIREN')
      expect(ep.uri.query).to match(/opt2=test&opt=plop&token=.+/)
    end

    it 'is an sirene endpoint' do
      ep = Endpoint.new(api_name: 'sirene', ping_url: '/')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to eq('sirene.entreprise.api.gouv.fr')
      expect(ep.uri.path).to eq('/')
      expect(ep.uri.query).to be_nil
    end
  end

  describe 'ping behaviour', vcr: { cassette_name: 'apie/v2_qualibat' } do
    subject(:ep) { create(:endpoint) }

    its(:http_response) { is_expected.to be_a(Net::HTTPResponse) }
    it 'is a correct uri' do
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/entreprise.api.gouv.fr/)
      expect(ep.uri.path).to eq('/v2/certificats_qualibat/33592022900036')
      expect(ep.uri.query).to match(/context=Ping&recipient=SGMAP&token=.+/)
    end
  end

  # Begin: ActiveRecord tests
  context 'when creating new endpoint with empty or invalid parameters' do
    describe 'invalid and unsavable object' do
      subject(:endpoint) { described_class.create }

      before { endpoint.valid? }

      it { is_expected.not_to be_valid }
      its(:save) { is_expected.to be_falsey }
    end

    describe 'has many errors' do
      subject { endpoint.errors.messages }

      let(:endpoint) { described_class.new }

      before { endpoint.valid? }

      its([:uname]) { is_expected.not_to be_empty }
      its([:name]) { is_expected.not_to be_empty }
      its([:api_name]) { is_expected.not_to be_empty }
      its([:api_version]) { is_expected.not_to be_empty }
      its([:provider]) { is_expected.not_to be_empty }
      its([:ping_period]) { is_expected.not_to be_empty }
      its([:ping_url]) { is_expected.not_to be_empty }
    end

    it 'has only hashes options' do
      endpoint = described_class.new(json_options: 'test')
      expect(endpoint).not_to be_valid
      expect(endpoint.errors.messages[:json_options].first).to eq('must be nil or a JSON string')
    end

    it 'uname must be Unique' do
      copy = create(:endpoint).dup
      expect(copy.save).to be_falsey
      expect(copy.errors.messages[:uname]).not_to be_empty
    end

    it 'api_version is an integer' do
      endpoint = described_class.new(api_version: 'oki')

      expect(endpoint).not_to be_valid
      expect(endpoint.errors.messages[:api_version]).not_to be_empty
    end

    it 'period is an integer' do
      endpoint = described_class.new(ping_period: 'test')
      expect(endpoint).not_to be_valid
      expect(endpoint.errors.messages[:ping_period]).not_to be_empty
    end
  end

  context 'when creating new endpoint with valid parameters' do
    subject { create(:endpoint) }

    it { is_expected.to be_valid }
    its(:save) { is_expected.to be_truthy }
  end

  context 'when creating new endpoint with valid parameters and empty options' do
    subject { create(:endpoint, json_options: nil) }

    it { is_expected.to be_valid }
    its(:save) { is_expected.to be_truthy }
  end

  context 'when loading endpoint' do
    subject { described_class.find_by(uname: 'apie_2_certificats_qualibat') }

    it { is_expected.to be_nil }

    context 'when endpoint exists' do
      before { create(:endpoint) }

      it { is_expected.not_to be_nil }
      its(:uname) { is_expected.to eq('apie_2_certificats_qualibat') }
    end
  end

  context 'when deleting endpoint' do
    subject(:endpoint) { described_class.find_by(uname: 'apie_2_certificats_qualibat') }

    before { create(:endpoint) }

    its(:delete) { is_expected.to be_truthy }
  end
  # End: ActiveRecord tests
end
