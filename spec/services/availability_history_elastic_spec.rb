require 'rails_helper'

describe AvailabilityHistoryElastic, type: :service do
  # TODO: share example to speed-up tests
  describe 'Availability history service', vcr: { cassette_name: 'availability_history' } do
    subject { described_class.new.get }

    it 'should be a success' do
      expect(subject.success?).to be_truthy
    end

    it 'should contains one element' do
      expect(subject.results.size).to equal(34) # TODO: why 34 instead of 33 ?? cf current_status
    end

    it 'should contains availability history' do
      subject.results.each do |endpoint|

        expect(endpoint['name']).not_to be_empty
        expect(endpoint['version']).to match(/v\d/)
        expect(endpoint['sla']).to be_a(Float)
        expect(endpoint['sla'].to_s).to match(/^\d+\.\d+$/)

        endpoint['availabilities'].each do |a|
          from = DateTime.parse(a[0])
          to = DateTime.parse(a[2])

          expect(a[0]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
          expect(a[2]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}[A-Z]/)
          expect(to).to be >= from

          expect(a[1]).to be_in([0, 1])
        end
      end
    end
  end
end
