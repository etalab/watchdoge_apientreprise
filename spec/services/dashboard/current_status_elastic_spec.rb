require 'rails_helper'

describe Dashboard::CurrentStatusElastic, type: :service do
  describe 'Current status service', vcr: { cassette_name: 'current_status' } do
    subject { described_class.new.get }

    it 'should be a success' do
      expect(subject.success?).to be_truthy
    end

    it 'should contains endpoints' do
      expect(subject.results.size).to equal(35)
    end

    it 'should contains endpoints with name and version...' do
      subject.results.each do |e|
        expect(e['name']).not_to be_empty
        expect(e['code']).to be_a(Integer)
        expect(e['code']).to be_between(200, 599)
        expect(e['api_version']).to be_in([1, 2])
        expect(e['timestamp']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
      end
    end
  end
end
