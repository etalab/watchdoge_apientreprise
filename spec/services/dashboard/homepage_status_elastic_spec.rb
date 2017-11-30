require 'rails_helper'

describe Dashboard::HomepageStatusElastic, type: :service do
  describe 'Homepage status service', vcr: { cassette_name: 'homepage_status' } do
    subject { described_class.new.get }

    it 'should be a success' do
      expect(subject.success?).to be_truthy
    end

    it 'should contains one element' do
      expect(subject.results.size).to equal(1)
    end

    it 'should contains homepage status' do
      expect(subject.results.dig(0,'name')).not_to be_empty
      expect(subject.results.dig(0,'code')).to be_a(Integer)
      expect(subject.results.dig(0,'code')).to be_between(200, 599)
      expect(subject.results.dig(0,'timestamp')).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
    end
  end
end
