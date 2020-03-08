require 'rails_helper'

describe EndpointFactory do
  describe 'endpoints returned are immutable (frozen)' do
    subject { described_class.new.find_endpoint_by_http_path(http_path: '/', api_name: 'apie') }

    it { is_expected.to be_frozen }
  end

  describe 'find by uname' do
    subject { described_class.new.find_endpoint_by_uname(uname) }

    context 'with a test on uname' do
      let(:uname) { 'apie_2_homepage' }

      its(:uname) { is_expected.to eq uname }
    end

    context 'with a test on wrong uname' do
      let(:uname) { 'bla bla bla' }

      it { is_expected.to be_nil }
    end
  end

  context 'with find_by_http_path' do
    subject { described_class.new.find_endpoint_by_http_path(http_path: http_path, api_name: 'apie') }

    #    describe 'find perfect match attestations cotisation retraite probtp' do
    #      let(:http_path) { '/v2/attestations_cotisation_retraite_probtp/73582032600040' }
    #
    #      its(:uname) { is_expected.to eq('apie_2_attestations_cotisation_retraite_probtp') }
    #    end
    #
    #    describe 'find regexp attestations cotisation retraite probtp' do
    #      let(:http_path) { '/v2/attestations_cotisation_retraite_probtp/73582032656485' }
    #
    #      its(:uname) { is_expected.to eq('apie_2_attestations_cotisation_retraite_probtp') }
    #    end

    describe 'finds perfect match msa' do
      let(:http_path) { '/v2/cotisations_msa/81104725700019' }

      its(:uname) { is_expected.to eq('apie_2_cotisations_msa') }
    end

    describe 'finds regexp match liasses fiscales' do
      let(:http_path) { 'v2/liasses_fiscales_dgfip/2016/declarations/811047257' }

      its(:uname) { is_expected.to eq('apie_2_liasses_fiscales_dgfip_declaration') }
    end

    describe 'finds regex doc asso with RNA ID' do
      let(:http_path) { '/v2/documents_associations/W262001597' }

      its(:uname) { is_expected.to eq('apie_2_documents_associations_rna') }
    end

    describe 'finds regex doc asso with Caledonian RNA ID' do
      let(:http_path) { '/v2/associations/W9N1004065' }

      its(:uname) { is_expected.to eq('apie_2_associations_rna') }
    end

    describe 'finds without paramter' do
      let(:http_path) { '/v2/liasses_fiscales_dgfip/2013/dictionnaire' }

      its(:uname) { is_expected.to eq('apie_2_liasses_fiscales_dgfip_dictionnaire') }
    end

    context 'when it is an EDGE CASE: finds v2 etablissements on perfect match' do
      let(:http_path) { '/v2/etablissements/41816609600069' }

      its(:uname) { is_expected.to eq('apie_2_etablissements') }
    end

    context 'when it is an EDGE CASE: finds v2 etablissements on regex match' do
      let(:http_path) { '/v2/etablissements/41816609612345' }

      its(:uname) { is_expected.to eq('apie_2_etablissements') }
    end
  end

  describe 'endpoint not found' do
    it 'logs an error with uname' do
      expect(Rails.logger).to receive(:error)
      described_class.new.find_endpoint_by_uname('bla bla')
    end

    it 'logs an error with wrong http_path' do
      expect(Rails.logger).to receive(:error)
      described_class.new.find_endpoint_by_http_path(http_path: 'v2/plop/wrong/url', api_name: 'apie')
    end

    it 'logs an error with wrong apie_name' do
      expect(Rails.logger).to receive(:error)
      described_class.new.find_endpoint_by_http_path(http_path: '/v2/cotisations_msa/81104725700019', api_name: 'mauvais api name')
    end
  end
end
