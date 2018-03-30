shared_examples 'elk invalid query' do |params = nil|
  describe 'failure', vcr: { cassette_name: 'invalid_queries' } do
    subject(:service) do
      if params.nil?
        described_class.new.tap(&:perform)
      else
        described_class.new(params).tap(&:perform)
      end
    end

    before do
      allow_any_instance_of(described_class).to receive(:json_query).and_return({ query: { match_allllll: {} } }.to_json)
    end

    its(:success?) { is_expected.to be_falsey }
    its(:errors) { is_expected.not_to be_empty }
  end
end
