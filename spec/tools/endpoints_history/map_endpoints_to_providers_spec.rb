require 'rails_helper.rb'

describe Tools::EndpointsHistory::MapEndpointsToProviders do
  subject { described_class.new(endpoints_history).to_json }

  let(:datetime1) { '2017-01-10 10:14:04' }
  let(:datetime2) { '2017-01-10 10:17:04' }
  let(:datetime3) { '2017-01-11 10:14:04' }
  let(:datetime4) { '2017-01-11 10:14:08' }
  let(:datetime5) { '2017-01-20 10:14:04' }
  let(:datetime6) { '2017-01-20 20:14:04' }

  let(:availability_history) { AvailabilityHistory.new }
  let(:endpoint_history_1) { EndpointHistory.new(name: 'name1', sub_name: 'sub name1', api_version: 2) }
  let(:endpoint_history_2) { EndpointHistory.new(name: 'name2', sub_name: nil, api_version: 2) }
  let(:endpoint_history_3) { EndpointHistory.new(name: 'name3', sub_name: 'sub name3', api_version: 1) }
  let(:endpoint_history_4) { EndpointHistory.new(name: 'name4', sub_name: 'sub name4', api_version: 2) }
  let(:endpoints_history) do
    [
      endpoint_history_1,
      endpoint_history_2,
      endpoint_history_3,
      endpoint_history_4
    ]
  end

  let(:providers_infos) do
    {
      'provider1': { name: 'provider1', endpoints_ids: %w[name1_sub_name1_2] },
      'provider2': { name: 'provider2', endpoints_ids: %w[name2__2 name3_sub_name3_1] },
      'provider3': { name: 'provider3', endpoints_ids: %w[name4_sub_name4_2] }
    }
  end

  let(:expected_json) do
    [
      {
        provider_name: 'provider1',
        endpoints_history: [
          { id: 'name1_sub_name1_2', name: 'name1', sub_name: 'sub name1', api_version: 2, sla: 9.6, availability_history: availability_history.to_a }
        ]
      },
      {
        provider_name: 'provider2',
        endpoints_history: [
          { id: 'name2__2', name: 'name2', sub_name: nil, api_version: 2, sla: 9.6, availability_history: availability_history.to_a },
          { id: 'name3_sub_name3_1', name: 'name3', sub_name: 'sub name3', api_version: 1, sla: 9.6, availability_history: availability_history.to_a }
        ]
      },
      {
        provider_name: 'provider3',
        endpoints_history: [
          { id: 'name4_sub_name4_2', name: 'name4', sub_name: 'sub name4', api_version: 2, sla: 9.6, availability_history: availability_history.to_a }
        ]
      }
    ]
  end

  before do
    availability_history.add_ping(1, datetime1)
    availability_history.add_ping(1, datetime2)
    availability_history.add_ping(1, datetime3)
    availability_history.add_ping(0, datetime4)
    availability_history.add_ping(0, datetime5)
    availability_history.add_ping(0, datetime6)

    endpoint_history_1.availability_history = availability_history
    endpoint_history_2.availability_history = availability_history
    endpoint_history_3.availability_history = availability_history
    endpoint_history_4.availability_history = availability_history

    allow_any_instance_of(described_class).to receive(:providers_infos).and_return(providers_infos)
  end

  it 'is the expected results' do
    is_expected.to include_json(expected_json)
  end
end
