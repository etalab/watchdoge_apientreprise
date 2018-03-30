require 'rails_helper'

describe Dashboard::HomepageStatusService, type: :service do
  describe 'response', vcr: { cassette_name: 'dashboard/homepage_status' } do
    subject { described_class.new.perform }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'dashboard/homepage_status' } do
    subject { service.results }

    let(:service) { described_class.new.perform }
    let(:json) { { results: service.results } }

    its(:size) { is_expected.to equal(1) }

    it 'matches json-schema' do
      expect(json).to match_json_schema('dashboard/homepage_status')
    end
  end

  it_behaves_like 'elk invalid query'
end
