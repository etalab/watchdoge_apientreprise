require 'rails_helper'

describe Dashboard::AvailabilityHistoryElastic, type: :service do
  describe 'Availability history service', vcr: { cassette_name: 'availability_history' } do
    subject { @availability_results_get }

    before do
      remember_through_tests('availability_results_get') do
        described_class.new.get
      end
    end

    it 'should be a success' do
      expect(subject.success?).to be_truthy
    end

    it 'should contains 13 element' do
      expect(subject.results.size).to equal(13)
    end

    it 'should contains specifics providers' do
      providers = subject.results.map{ |r| r['provider_name'] }.sort
      expected_providers = Tools::EndpointFactory.new('apie').providers_infos.keys.sort
      expected_providers.delete('apie')
      expect(expected_providers).to eq(providers)
    end

    it 'should contains availability history' do
      subject.results.each do |provider|
        expect(provider['provider_name']).not_to be_empty

        provider['endpoints_history'].each do |ep|
          expect(ep['id']).to be_a(String)
          expect(ep['name']).to be_a(String)
          expect(ep['api_version']).to be_in([1, 2])
          expect(ep['sla']).to be_a(Float)
          expect(ep['sla'].to_s).to match(/^\d+\.\d+$/)
          expect(ep['sla']).to be > 65

          ep['availabilities'].each do |a|
            from = DateTime.parse(a[0])
            to = DateTime.parse(a[2])

            expect(a[0]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
            expect(a[2]).to match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
            expect(to).to be >= from

            expect(a[1]).to be_in([0, 1])
          end
        end
      end
    end
  end
end
