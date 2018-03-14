require 'rails_helper'

describe ElasticClient, type: :service do
  subject(:client) { described_class.new }

  before do
    client.establish_connection
    client.perform basic_json_query
  end

  let(:basic_json_query) do
    {
      "size": 1,
      "query": {
        "match_all": {}
      }
    }
  end

  context 'when API access is allowed', vcr: { cassette_name: 'basic_json_query_allowed' } do
    its(:success?) { is_expected.to be_truthy }
    its(:raw_response) { is_expected.to be_kind_of(Hash) }
    its(:errors) { is_expected.to be_empty }
  end

  # VCR cassette is not generated but it is mandatory a HTTP request is performed
  describe 'when API access is forbidden', vcr: { cassette_name: 'basic_json_query_denied' } do
    its(:success?) { is_expected.to be_falsey }
    its(:raw_response) { is_expected.to be_nil }
    its(:errors) { is_expected.not_to be_empty }
  end
end
