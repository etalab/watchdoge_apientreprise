require 'rails_helper'

describe Dashboard::CurrentStatusService, type: :service do
  describe 'response', vcr: { cassette_name: 'dashboard/current_status' } do
    subject { described_class.new.perform }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'dashboard/current_status' } do
    subject(:results) { service.results }

    let(:service) { described_class.new.perform }
    let(:json) { { results: service.results } }
    let(:endpoints_unames) { results.map { |e| e['uname'] }.sort }
    let(:expected_endpoints_unames) do
      %w[apie_2_bilans_entreprises_bdf apie_2_certificats_qualibat apie_2_etablissements apie_2_etablissements_legacy apie_2_liasses_fiscales_dgfip_complete apie_2_liasses_fiscales_dgfip_declaration apie_2_liasses_fiscales_dgfip_dictionnaire apie_2_documents_associations_rna apie_2_associations_rna apie_2_attestations_agefiph apie_2_attestations_cotisation_retraite_probtp apie_2_attestations_fiscales_dgfip apie_2_attestations_sociales_acoss apie_2_cartes_professionnelles_fntp apie_2_certificats_cnetp apie_2_certificats_opqibi apie_2_cotisations_msa apie_2_eligibilites_cotisation_retraite_probtp apie_2_entreprises apie_2_entreprises_legacy apie_2_etablissements_predecesseur apie_2_etablissements_successeur apie_2_exercices_dgfip apie_2_extraits_courts_inpi apie_2_extraits_rcs_infogreffe].sort
    end

    its(:size) { is_expected.to equal(25) }

    it 'matches json-schema' do
      expect(json).to match_json_schema('dashboard/current_status')
    end

    it 'contains specifics endpoints names and sub_names' do
      expect(endpoints_unames).to eq(expected_endpoints_unames)
    end
  end

  it_behaves_like 'elk invalid query'

  context 'with unknwon element' do
    subject(:service) { described_class.new.perform }

    let(:results) { service.results }
    let(:unknwon_endpoint) do
      {
        key: 'bli/blou/unknwon',
        agg_by_endpoint:  {
          hits:  {
            hits: [{
              _index: 'logstash-2018.05.22',
              _type: 'siade',
              _id: 'AWOIvWf6y-__1jNGzSfE',
              _score: nil,
              _source: {
                path: 'bli/blou/unknwon',
                '@timestamp': '2018-05-22T16 : 45 : 03.543Z',
                status: 500
              },
              sort: [1_527_007_503_543]
            }]
          }
        }
      }.deep_stringify_keys
    end

    before do
      allow_any_instance_of(ElasticClient).to receive(:connected?).and_return(true)
      allow_any_instance_of(ElasticClient).to receive(:establish_connection)
      allow_any_instance_of(ElasticClient).to receive(:search).and_return(nil)
      allow_any_instance_of(ElasticClient).to receive(:success?).and_return(true)

      allow_any_instance_of(described_class).to receive(:raw_endpoints).and_return([unknwon_endpoint])
    end

    its(:success?) { is_expected.to be_truthy }

    it 'size' do
      expect(results.size).to equal(0)
    end
  end
end
