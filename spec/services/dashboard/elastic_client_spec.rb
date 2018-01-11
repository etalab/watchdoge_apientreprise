require 'rails_helper'

describe Dashboard::ElasticClient, type: :service do
  subject { service }

  let(:service) { described_class.new.perform(basic_json_query) }

  let(:basic_json_query) do
    {
      "size": 1,
      "query": {
        "match_all": {}
      }
    }
  end

  context 'when API access is allowed', vcr: { cassette_name: 'basic_json_query_allowed' } do
    its(:success?) { is_expected.to be_truthy}
    its(:raw_response) { is_expected.to be_kind_of(Hash) }
    its(:errors) { is_expected.to be_empty }
  end

  describe 'when API access is forbidden', vcr: { cassette_name: 'basic_json_query_denied' } do
    its(:success?) { is_expected.to be_falsey}
    its(:raw_response) { is_expected.to be_nil }
    its(:errors) { is_expected.not_to be_empty }
  end
end
