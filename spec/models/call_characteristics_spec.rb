require 'rails_helper'

describe CallCharacteristics do
  subject { described_class.new(endpoint_factory, source_example) }

  let(:endpoint_factory) { EndpointFactory.new }
  let(:source_example) { JSON.parse(File.read(filename)) }

  describe 'parsing Etablissements Legacy v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/legacy_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_2_etablissements_legacy') }
    its(:name) { is_expected.to eq('Etablissements (legacy)') }
    its(:provider) { is_expected.to eq('insee') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(503) }
    its(:timestamp) { is_expected.to eq('2017-12-03T17:50:03.760Z') }
    its(:provider_name) { is_expected.to be_nil }
    its(:fallback_used) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v2/etablissements_legacy/41816609600069') }
    its(:to_json) { is_expected.to include_json(uname: 'apie_2_etablissements_legacy', name: 'Etablissements (legacy)', api_version: 2, provider: 'insee', code: 503, timestamp: '2017-12-03T17:50:03.760Z', provider_name: nil, fallback_used: nil) }
  end

  describe 'parsing Entreprises v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/entreprises_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_2_entreprises') }
    its(:name) { is_expected.to eq('Entreprise') }
    its(:provider) { is_expected.to eq('insee') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2018-01-28T13:01:12.982Z') }
    its(:provider_name) { is_expected.to eq('insee') }
    its(:fallback_used) { is_expected.to be_falsey }
    its(:http_path) { is_expected.to eq('/v2/entreprises/418166096') }
    its(:to_json) { is_expected.to include_json(uname: 'apie_2_entreprises', name: 'Entreprise', api_version: 2, provider: 'insee', code: 200, timestamp: '2018-01-28T13:01:12.982Z', provider_name: 'insee', fallback_used: false) }
  end

  describe 'parsing Infogreffe v1' do
    let(:filename) { 'spec/support/payload_files/elk_sources/extraits_rcs_infogreffe_source.json' }

    its(:uname) { is_expected.to eq('apie_1_extraits_rcs_infogreffe') }
    its(:name) { is_expected.to eq('Extraits RCS (Infogreffe)') }
    its(:provider) { is_expected.to eq('infogreffe') }
    its(:api_version) { is_expected.to eq(1) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2018-01-03T00:01:15.418Z') }
    its(:provider_name) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v1/infogreffe/extraits_rcs/418166096') }
  end

  describe 'parsing msa v1' do
    let(:filename) { 'spec/support/payload_files/elk_sources/msa_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_1_cotisations_msa') }
    its(:name) { is_expected.to eq('Cotisations MSA') }
    its(:provider) { is_expected.to eq('msa') }
    its(:api_version) { is_expected.to eq(1) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2017-12-03T18:00:02.962Z') }
    its(:provider_name) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v1/msa/cotisations/81104725700019') }
  end

  describe 'parsing liasse fiscale v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/liasses_fiscales_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_2_liasses_fiscales_dgfip_declaration') }
    its(:name) { is_expected.to eq('Liasses fiscales (déclaration)') }
    its(:provider) { is_expected.to eq('dgfip') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2017-12-03T18:00:35.011Z') }
    its(:provider_name) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v2/liasses_fiscales_dgfip/2016/declarations/301028346') }
  end
end
