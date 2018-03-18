require 'rails_helper'

describe Endpoint, type: :model do
  # Begin: real testing
  context 'with one redirection' do
    let(:uname) { 'apie_2_homepage_test' }

    before { create(:endpoint, uname: uname, provider: 'apientreprise', http_path: '/') }

    it 'follows redirection once', vcr: { cassette_name: 'apie/v2_homepage' } do
      expect_any_instance_of(described_class).to receive(:fetch_with_redirection).exactly(:twice).and_call_original
      described_class.find_by(uname: uname).http_response
    end
  end

  describe 'all endpoints must be valids' do
    pending('Pb: Certificate Sirene / Attestations Fiscales / Liasses Fiscales / RNA / MSA')
    # it 'return 200 for all endpoints', vcr: { cassette_name: 'apie_all' } do
    #   Endpoint.all.each do |ep|
    #     response = described_class.find_by(uname: ep.uname).http_response
    #     binding.pry if response.code != '200'
    #     expect(response).to be_a(Net::HTTPResponse)
    #     expect(response.code).to eq('200')
    #   end
    # end

    it 'return 200: qualibat v2', vcr: { cassette_name: 'apie/v2_qualibat' } do
      response = described_class.find_by(uname: 'apie_2_certificats_qualibat').http_response
      expect(response).to be_a(Net::HTTPResponse)
      expect(response.code).to eq('200')
    end
  end
  # End: real testing

  describe 'url is always good' do
    it 'is an apie v1 endpoint' do
      ep = create(:endpoint, api_name: 'apie', api_version: 1, http_path: '/v1/toto/SIREN')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/apientreprise.fr/)
      expect(ep.uri.path).to eq('/v1/toto/SIREN')
      expect(ep.uri.query).to match(/token=.+/)
    end

    it 'is an apie v2 endpoint' do
      ep = create(:endpoint, api_name: 'apie', api_version: 2, http_path: '/v2/toto/SIREN')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/entreprise.api.gouv.fr/)
      expect(ep.uri.path).to eq('/v2/toto/SIREN')
      expect(ep.uri.query).to match(/token=.+/)
    end

    it 'is an apie v2 endpoint with options' do
      ep = create(:endpoint, api_name: 'apie', api_version: 2, http_path: '/v2/toto/SIREN', http_query: '{"opt": "plop", "opt2": "test"}')
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/entreprise.api.gouv.fr/)
      expect(ep.uri.path).to eq('/v2/toto/SIREN')
      expect(ep.uri.query).to match(/opt2=test&opt=plop&token=.+/)
    end

    it 'is an sirene endpoint' do
      ep = create(:endpoint, api_name: 'sirene', http_path: '/', http_query: nil)
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to eq('entreprise.data.gouv.fr')
      expect(ep.uri.path).to eq('/')
      expect(ep.uri.query).to be_empty
    end
  end

  describe 'ping behaviour', vcr: { cassette_name: 'apie/v2_qualibat' } do
    subject(:ep) { Endpoint.find_by(uname: 'apie_2_certificats_qualibat') }

    its(:http_response) { is_expected.to be_a(Net::HTTPResponse) }

    it 'is a correct uri' do
      expect(ep.uri.scheme).to eq('https')
      expect(ep.uri.host).to match(/entreprise.api.gouv.fr/)
      expect(ep.uri.path).to eq('/v2/certificats_qualibat/33592022900036')
      expect(ep.uri.query).to match(/context=Ping&object=Watchdoge&recipient=SGMAP&token=.+/)
    end
  end

  context 'when Net::HTTP request raises' do
    describe 'a Net::HTTPError' do
      subject(:ep) { Endpoint.find_by(uname: 'apie_2_certificats_qualibat') }

      before { allow(Net::HTTP).to receive(:get_response).and_raise(Net::HTTPError) }

      it 'log an error' do
        expect(Rails.logger).to receive(:error).with('Something wrong happened when make the http request (wrong number of arguments (given 0, expected 2))')
        ep.http_response
      end
    end

    describe 'a Net::HTTPBadResponse' do
      subject(:ep) { Endpoint.find_by(uname: 'apie_2_certificats_qualibat') }

      before { allow(Net::HTTP).to receive(:get_response).and_raise(Net::HTTPBadResponse) }

      it 'log an error' do
        expect(Rails.logger).to receive(:error).with('Something wrong happened when make the http request (Net::HTTPBadResponse)')
        ep.http_response
      end
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
      its([:http_path]) { is_expected.not_to be_empty }
    end

    it 'has only hashes options' do
      endpoint = described_class.new(http_query: 'test')
      expect(endpoint).not_to be_valid
      expect(endpoint.errors.messages[:http_query].first).to eq('must be nil or a JSON string')
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
    subject { create(:endpoint, http_query: nil) }

    it { is_expected.to be_valid }
    its(:save) { is_expected.to be_truthy }
  end

  context 'when loading endpoint' do
    subject { described_class.find_by(uname: 'not_existing_uname') }

    it { is_expected.to be_nil }

    context 'when endpoint exists' do
      subject { described_class.find_by(uname: 'apie_2_certificats_test') }

      before { create(:endpoint) }

      it { is_expected.not_to be_nil }
      its(:uname) { is_expected.to eq('apie_2_certificats_test') }
    end
  end

  context 'when deleting endpoint' do
    subject(:endpoint) { described_class.find_by(uname: 'apie_2_certificats_qualibat') }

    before { create(:endpoint) }

    its(:delete) { is_expected.to be_truthy }
  end
  # End: ActiveRecord tests
end
