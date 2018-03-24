require 'rails_helper'

describe Dashboard::EndpointsAvailabilityAdapter do
  let(:datetime1) { '2017-01-10 10:14:04' }
  let(:datetime2) { '2017-01-10 10:17:04' }
  let(:datetime3) { '2017-01-11 10:14:04' }
  let(:datetime4) { '2017-01-11 10:14:08' }
  let(:datetime5) { '2017-01-20 10:14:04' }
  let(:datetime6) { '2017-01-20 20:14:04' }

  let(:availability_history) { Dashboard::AvailabilityHistory.new }
  let(:endpoint_avail_history_1) { Dashboard::EndpointAvailabilityHistory.new(endpoint: create(:endpoint, uname: 'name1'), timezone: 'Europe/Paris') }
  let(:endpoint_avail_history_2) { Dashboard::EndpointAvailabilityHistory.new(endpoint: create(:endpoint, uname: 'name2'), timezone: 'Europe/Paris') }
  let(:endpoint_avail_history_3) { Dashboard::EndpointAvailabilityHistory.new(endpoint: create(:endpoint, uname: 'name3', provider: 'provider_test'), timezone: 'Europe/Paris') }
  let(:endpoint_avail_history_4) { Dashboard::EndpointAvailabilityHistory.new(endpoint: create(:endpoint, uname: 'name4', provider: 'provider_test'), timezone: 'Europe/Paris') }
  let(:endpoints_availability_history) do
    [
      endpoint_avail_history_1,
      endpoint_avail_history_2,
      endpoint_avail_history_3,
      endpoint_avail_history_4
    ]
  end

  before do
    availability_history.aggregate(206, datetime1)
    availability_history.aggregate(200, datetime2)
    availability_history.aggregate(212, datetime3)
    availability_history.aggregate(500, datetime4)
    availability_history.aggregate(500, datetime5)
    availability_history.aggregate(512, datetime6)

    endpoint_avail_history_1.availability_history = availability_history
    endpoint_avail_history_2.availability_history = availability_history
    endpoint_avail_history_3.availability_history = availability_history
    endpoint_avail_history_4.availability_history = availability_history
  end

  it 'is the expected results' do
    json = { results: described_class.new(endpoints_availability_history).to_json_provider_list }
    expect(json).to match_json_schema('dashboard/availability_history')
  end
end
