require 'rails_helper'

describe Tools::ElasticsearchSourceParser do
  subject { described_class.parse(source_example) }

  let(:source_example) { JSON.parse(File.read(filename)) }

  describe 'basic parsing' do
    let(:filename) { 'spec/support/payload_files/legacy_elasticsearch_source.json' }
    let(:expected_results) do
      {
        name: 'etablissements_legacy',
        sub_name: nil,
        api_version: 2,
        code: 503,
        timestamp: '2017-12-03T17:50:03.760Z'
      }
    end

    it 'is a valid parsing' do
      is_expected.to eq(expected_results)
    end
  end

  describe 'parsing with sub_name' do
    let(:filename) { 'spec/support/payload_files/msa_elasticsearch_source.json' }
    let(:expected_results) do
      {
        name: 'msa',
        sub_name: 'cotisations',
        api_version: 1,
        code: 200,
        timestamp: '2017-12-03T18:00:02.962Z'
      }
    end

    it 'is a valid parsing' do
      is_expected.to eq(expected_results)
    end
  end

  describe 'parsing with liasse fiscale' do
    let(:filename) { 'spec/support/payload_files/liasses_fiscales_elasticsearch_source.json' }
    let(:expected_results) do
      {
        name: 'liasses_fiscales_dgfip',
        sub_name: 'declaration',
        api_version: 2,
        code: 200,
        timestamp: '2017-12-03T18:00:35.011Z'
      }
    end

    it 'is a valid parsing' do
      is_expected.to eq(expected_results)
    end
  end
end
