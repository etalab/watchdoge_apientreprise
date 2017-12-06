require 'rails_helper'

describe Dashboard::CurrentStatusElastic, type: :service do
  describe 'response', vcr: { cassette_name: 'current_status' } do
    subject { described_class.new.get }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'current_status' } do
    subject(:results) { service.results }

    let(:service) { described_class.new.get }
    let(:json) { { results: service.results } }
    let(:endpoints_names) { results.map { |e| "#{e['name']}_#{e['sub_name']}_#{e['api_version']}" }.sort }
    let(:expected_endpoints_names) do
      %w[etablissements__1 etablissements_legacy__2 certificats_qualibat__1 certificats_qualibat__2 etablissements__2 liasses_fiscales_dgfip__2 attestations_cotisation_retraite_probtp__1 attestations_fiscales__1 entreprises__1 exercices__1 infogreffe_extraits_rcs_1 msa_cotisations_1 opqibi_certificat_1 certificats_cnetp__1 eligibilites_cotisation_retraite_probtp__1 attestations_agefiph__2 exercices__2 entreprises_legacy__2 associations__1 attestations_cotisation_retraite_probtp__2 attestations_fiscales_dgfip__2 certificats_cnetp__2 entreprises__2 extraits_rcs_infogreffe__2 associations__2 attestations_sociales_acoss__2 cartes_professionnelles_fntp__2 certificats_opqibi__2 documents_associations__2 eligibilites_cotisation_retraite_probtp__2 etablissements_predecesseur_2 etablissements_successeur_2 extraits_courts_inpi__2 attestations_sociales__1 cotisations_msa__2 fntp_carte_pro_1].sort
    end

    its(:size) { is_expected.to equal(36) }

    it 'matches json-schema' do
      expect(json).to match_json_schema('current_status')
    end

    it 'contains specifics endpoints names and sub_names' do
      expect(endpoints_names).to eq(expected_endpoints_names)
    end
  end

  describe 'invalid query', vcr: { cassette_name: 'invalid_query' } do
    subject { described_class.new.get }

    before do
      allow_any_instance_of(described_class).to receive(:load_query).and_return(query: { match_allllll: {} })
    end

    its(:success?) { is_expected.to be_falsey }
  end
end
