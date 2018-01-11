require 'rails_helper'

describe Dashboard::CurrentStatusElastic, type: :service do
  before { Tools::EndpointDatabaseFiller.instance.refill_database }

  describe 'response', vcr: { cassette_name: 'current_status' } do
    subject { described_class.new.perform }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'current_status' } do
    subject(:results) { service.results }

    let(:service) { described_class.new.perform }
    let(:json) { { results: service.results } }
    let(:endpoints_unames) { results.map { |e| e['uname'] }.sort }
    let(:expected_endpoints_unames) do
      %w[apie_1_certificats_qualibat apie_1_etablissements apie_2_certificats_qualibat apie_2_etablissements apie_2_etablissements_legacy apie_2_liasses_fiscales_dgfip_complete apie_2_documents_associations_rna apie_1_associations_rna apie_1_attestations_cotisation_retraite_probtp apie_1_attestations_fiscales_dgfip apie_1_eligibilite_cotisation_retraite_probtp apie_1_entreprises apie_1_exercices_dgfip apie_1_extraits_rcs_infogreffe apie_1_cotisations_msa apie_1_certificat_opqibi apie_2_associations_rna apie_2_attestations_agefiph apie_2_attestations_cotisation_retraite_probtp apie_2_attestations_fiscales_dgfip apie_2_attestations_sociales_acoss apie_2_cartes_professionnelles_fntp apie_2_certificats_cnetp apie_2_certificats_opqibi apie_2_cotisations_msa apie_2_eligibilites_cotisation_retraite_probtp apie_2_entreprises apie_2_entreprises_legacy apie_2_etablissements_predecesseur apie_2_etablissements_successeur apie_2_exercices_dgfip apie_2_extraits_courts_inpi apie_2_extraits_rcs_infogreffe apie_1_certificat_cnetp apie_1_attestations_sociales_acoss apie_1_cartes_professionnelles_fntp].sort
    end

    its(:size) { is_expected.to equal(36) }

    it 'matches json-schema' do
      expect(json).to match_json_schema('current_status')
    end

    it 'contains specifics endpoints names and sub_names' do
      expect(endpoints_unames).to eq(expected_endpoints_unames)
    end
  end

  describe 'invalid query', vcr: { cassette_name: 'invalid_query' } do
    subject { described_class.new.perform }

    before do
      allow_any_instance_of(described_class).to receive(:json_query).and_return(query: { match_allllll: {} })
    end

    its(:success?) { is_expected.to be_falsey }
  end
end
