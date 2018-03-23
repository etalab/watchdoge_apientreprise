require 'rails_helper'

describe Dashoard::PingHistoryAggregator, vcr: { cassette_name: 'dashboard/availability_history_shortened' } do
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

  it 'is an array' do
    is_expected.to be_a(Array)
  end

  its(:size) { is_expected.to eq(Endpoint.where(api_name: 'apie').where.not(provider: 'apientreprise').size) }

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
