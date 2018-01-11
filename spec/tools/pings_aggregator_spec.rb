require 'rails_helper'

describe Tools::PingsAggregator, vcr: { cassette_name: 'availability_history_shortened' } do
  subject(:endpoints_history) { @endpoints_history_subject.endpoints_history }

  let(:timezone) { 'Asia/Jerusalem' }

  before do
    Tools::EndpointDatabaseFiller.instance.refill_database

    allow_any_instance_of(Dashboard::AvailabilityHistoryService).to receive(:query_name).and_return('availability_history_shortened')
    remember_through_tests('endpoints_history_subject') do
      service = Dashboard::AvailabilityHistoryService.new
      service.send(:retrieve_all_availability_history)
      raw_data = service.send(:hits)
      described_class.new(raw_data, timezone)
    end
  end

  it 'is an array' do
    is_expected.to be_a(Array)
  end

  its(:size) { is_expected.to eq(Endpoint.where(api_name: 'apie').where.not(provider: 'apientreprise').size) }

  # rubocop:disable RSpec/ExampleLength
  it 'is an array of EndpointHistory' do
    endpoints_history.each do |eh|
      expect(eh).to be_a(EndpointHistory)
      expect(eh).to be_valid
      expect(eh.timezone).to eq(timezone)
      expect(eh.availability_history).to be_a(AvailabilityHistory)
    end
  end
end
