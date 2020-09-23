require 'rails_helper'

describe Dashboard::PingHistoryAggregator do
  context 'with valid input', vcr: { cassette_name: 'dashboard/availability_history_shortened' } do
    # rubocop:disable RSpec/InstanceVariable
    subject(:endpoints_availability_history) { @endpoints_history_subject.endpoints_availability_history }

    # rubocop:enable RSpec/InstanceVariable

    let(:timezone) { 'Asia/Jerusalem' }

    before do
      allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:query_name).and_return('availability_history_shortened')
      remember_through_tests('endpoints_history_subject') do
        service = Dashboard::AvailabilityHistoryService.new
        service.send(:retrieve_all_availabilities)
        raw_data = service.send(:hits)
        described_class.new(raw_data, timezone)
      end
    end

    it { is_expected.to be_a(Array) }

    its(:size, skip: 'Stop testing that') { is_expected.to eq(Endpoint.where("api_name= 'apie' and provider != 'apientreprise' and api_version = 2").size) }

    # rubocop:disable RSpec/ExampleLength
    it 'is an array of EndpointAvailabilityHistory' do
      endpoints_availability_history.each do |eh|
        expect(eh).to be_a(Dashboard::EndpointAvailabilityHistory)
        expect(eh).to be_valid
        expect(eh.timezone).to eq(timezone)
        expect(eh.availability_history).to be_a(Dashboard::AvailabilityHistory)
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context 'with unknown data' do
    subject { described_class.new(raw_data, 'Paris/Europe').endpoints_availability_history }

    let(:raw_data) { [JSON.parse(File.read('spec/support/payload_files/unknown_elasticsearch_raw_data.json'))] }

    its(:size) { is_expected.to eq(0) }
  end
end
