require 'rails_helper'

describe Dashboard::CurrentStatusElastic, type: :service do
  describe 'response', vcr: { cassette_name: 'current_status' } do
    subject { described_class.new.get }

    its(:success?) { is_expected.to be_truthy }
  end

  describe 'results', vcr: { cassette_name: 'current_status' } do
    subject(:temp) { service.results }

    let(:service) { described_class.new.get }

    its(:size) { is_expected.to equal(35) }

    # TODO: json-schema
    # rubocop:disable RSpec/ExampleLength
    it 'contains endpoints with name and version...' do
      temp.each do |e|
        expect(e['name']).not_to be_empty
        expect(e['code']).to be_a(Integer)
        expect(e['code']).to be_between(200, 599)
        expect(e['api_version']).to be_in([1, 2])
        expect(e['timestamp']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
      end
    end
  end
end
