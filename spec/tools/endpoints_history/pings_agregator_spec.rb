require 'rails_helper.rb'

describe Tools::EndpointsHistory::PingsAgregator, vcr: { cassette_name: 'availability_history' } do
  subject(:endpoints_history) { @endpoints_history_subject.to_endpoints_history }

  let(:timezone) { 'Asia/Jerusalem' }

  before do
    remember_through_tests('endpoints_history_subject') do
      service = Dashboard::AvailabilityHistoryElastic.new
      service.send(:get_all_availability_history)
      raw_data = service.send(:hits)
      described_class.new(raw_data, timezone)
    end
  end

  it 'is an array' do
    is_expected.to be_a(Array)
  end

  its(:size) { is_expected.to eq(34) }

  it 'is an array of EndpointHistory' do
    endpoints_history.each do |eh|
      expect(eh).to be_a(EndpointHistory)
      expect(eh.timezone).to eq(timezone)
      expect(eh.availability_history).to be_a(AvailabilityHistory)
    end
  end
end
