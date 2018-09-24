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
    let(:elements) { Endpoint.where("api_name = 'apie' and provider != 'apientreprise'") }
    let(:nb_elements) { elements.size }
    let(:expected_endpoints_unames) { elements.map(&:uname).sort }

    its(:size) { is_expected.to equal(nb_elements) }

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
