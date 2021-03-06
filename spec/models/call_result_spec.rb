require 'rails_helper'

describe CallResult do
  subject { described_class.new(source_example, endpoint_factory) }

  let(:endpoint_factory) { EndpointFactory.new }
  let(:source_example) { JSON.parse(File.read(filename)) }

  describe 'parsing an element with a different parameter than in the database' do
    let(:filename) { 'spec/support/payload_files/elk_sources/certificat_rge_ademe_source.json' }
    let(:new_siret) { '82525962500010' }
    let(:new_path) { "/v2/certificats_rge_ademe/#{new_siret}" }

    before do
      source_example['path'] = new_path
      source_example['parameters']['siret'] = new_siret
    end

    its(:params) { is_expected.to include({ siret: new_siret }) }
    its(:http_path) { is_expected.to match(%r{^\/v2\/certificats_rge_ademe\/#{new_siret}$}) }
  end

  describe 'parsing source without parameters' do
    before do
      source_example.delete_if { |k| k == 'parameters' }
    end

    let(:filename) { 'spec/support/payload_files/elk_sources/certificat_rge_ademe_source.json' }

    its(:params) { is_expected.to be_nil }
    its(:uname) { is_expected.to eq('apie_2_certificats_rge_ademe') }
  end

  describe 'parsing Etablissements Legacy v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/certificat_rge_ademe_source.json' }

    its(:uname) { is_expected.to eq('apie_2_certificats_rge_ademe') }
    its(:name) { is_expected.to eq('Certificats RGE ADEME') }
    its(:provider) { is_expected.to eq('ademe') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2020-10-26T13:06:39.691Z') }
    its(:params) { is_expected.to contain_exactly({ context: 'APS' }, { recipient: '44313931600022' }, { siret: '44313931600022' }, { object: 'test' }) }
    its(:provider_name) { is_expected.to be_nil }
    its(:fallback_used) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v2/certificats_rge_ademe/44313931600022') }
    its(:as_json) { is_expected.to include_json(uname: 'apie_2_certificats_rge_ademe', name: 'Certificats RGE ADEME', api_version: 2, provider: 'ademe', code: 200, timestamp: '2020-10-26T13:06:39.691Z', provider_name: nil, fallback_used: nil) }
  end

  describe 'parsing Entreprises v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/entreprises_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_2_entreprises') }
    its(:name) { is_expected.to eq('Entreprise') }
    its(:provider) { is_expected.to eq('insee') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2018-01-28T13:01:12.982Z') }
    its(:params) { is_expected.to contain_exactly({ context: 'Ping' }, { recipient: 'SGMAP' }, { siren: '418166096' }) }
    its(:provider_name) { is_expected.to eq('insee') }
    its(:fallback_used) { is_expected.to be_falsey }
    its(:http_path) { is_expected.to eq('/v2/entreprises/418166096') }
    its(:as_json) { is_expected.to include_json(uname: 'apie_2_entreprises', name: 'Entreprise', api_version: 2, provider: 'insee', code: 200, timestamp: '2018-01-28T13:01:12.982Z', provider_name: 'insee', fallback_used: false) }
  end

  describe 'parsing Infogreffe v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/extraits_rcs_infogreffe_source.json' }

    its(:uname) { is_expected.to eq('apie_2_extraits_rcs_infogreffe') }
    its(:name) { is_expected.to eq('Extraits RCS (Infogreffe)') }
    its(:provider) { is_expected.to eq('infogreffe') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2018-05-27T16:00:08.830Z') }
    its(:params) { is_expected.to contain_exactly({ context: 'Ping' }, { recipient: 'SGMAP' }, { object: 'Watchdoge' }, { siren: '418166096' }) }
    its(:provider_name) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v2/extraits_rcs_infogreffe/418166096') }
  end

  describe 'parsing msa v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/msa_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_2_cotisations_msa') }
    its(:name) { is_expected.to eq('Cotisations MSA') }
    its(:provider) { is_expected.to eq('msa') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2018-05-27T16:00:05.771Z') }
    its(:params) { is_expected.to contain_exactly({ context: 'Ping' }, { recipient: 'SGMAP' }, { object: 'Watchdoge' }, { siret: '81104725700019' }) }
    its(:provider_name) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v2/cotisations_msa/81104725700019') }
  end

  describe 'parsing liasse fiscale v2' do
    let(:filename) { 'spec/support/payload_files/elk_sources/liasses_fiscales_elasticsearch_source.json' }

    its(:uname) { is_expected.to eq('apie_2_liasses_fiscales_dgfip_declaration') }
    its(:name) { is_expected.to eq('Liasses fiscales (déclaration)') }
    its(:provider) { is_expected.to eq('dgfip') }
    its(:api_version) { is_expected.to eq(2) }
    its(:code) { is_expected.to eq(200) }
    its(:timestamp) { is_expected.to eq('2017-12-03T18:00:35.011Z') }
    its(:params) { is_expected.to contain_exactly({ siren: '301028346' }, { context: 'Ping' }, { recipient: 'SGMAP' }, { annee: '2016' }) }
    its(:provider_name) { is_expected.to be_nil }
    its(:http_path) { is_expected.to eq('/v2/liasses_fiscales_dgfip/2016/declarations/301028346') }
  end

  describe 'parsing unknown payload' do
    let(:filename) { 'spec/support/payload_files/elk_sources/unknown_elasticsearch_source.json' }

    its(:valid?) { is_expected.to be_falsey }
  end
end
