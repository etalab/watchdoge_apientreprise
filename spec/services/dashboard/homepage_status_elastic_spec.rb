require 'rails_helper'

describe Dashboard::HomepageStatusElastic, type: :service do
  describe 'response', vcr: { cassette_name: 'homepage_status' } do
    subject { described_class.new.get }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'homepage_status' } do
    subject { service.results }

    let(:service) { described_class.new.get }
    let(:json) { { results: service.results } }

    its(:size) { is_expected.to equal(1) }

    it 'matches json-schema' do
      expect(json).to match_json_schema('homepage_status')
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
