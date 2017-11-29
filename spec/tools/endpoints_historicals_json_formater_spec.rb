require 'rails_helper.rb'

describe Tools::EndpointsHistoricalsJSONFormater do
  subject(:json) { described_class.new.format_to_json(endpoints_historicals) }

  let(:datetime1) { '2017-01-10 10:14:04' }
  let(:datetime2) { '2017-01-10 10:17:04' }
  let(:datetime3) { '2017-01-11 10:14:04' }
  let(:datetime4) { '2017-01-11 10:14:08' }
  let(:datetime5) { '2017-01-20 10:14:04' }
  let(:datetime6) { '2017-01-20 20:14:04' }

  let(:availabilities) { Availabilities.new }
  let(:endpoint_historical_1) { EndpointHistorical.new(name: 'name1', sub_name: 'sub name1', api_version: 2) }
  let(:endpoint_historical_2) { EndpointHistorical.new(name: 'name2', sub_name: nil, api_version: 2) }
  let(:endpoint_historical_3) { EndpointHistorical.new(name: 'name3', sub_name: 'sub name3', api_version: 1) }
  let(:endpoint_historical_4) { EndpointHistorical.new(name: 'name4', sub_name: 'sub name4', api_version: 2) }
  let(:endpoints_historicals) do
    {
      "#{endpoint_historical_1.id}": endpoint_historical_1,
      "#{endpoint_historical_2.id}": endpoint_historical_2,
      "#{endpoint_historical_3.id}": endpoint_historical_3,
      "#{endpoint_historical_4.id}": endpoint_historical_4
    }
  end

  let(:providers_infos) do
    {
      'provider1': { name: 'provider1', endpoints_ids: ['name1_sub_name1_2'] },
      'provider2': { name: 'provider2', endpoints_ids: ['name2__2', 'name3_sub_name3_1'] },
      'provider3': { name: 'provider3', endpoints_ids: ['name4_sub_name4_2'] }
    }
  end

  let(:expected_json) do
    [
      {
        provider_name: 'provider1',
        endpoints_historicals: [
          { id: 'name1_sub_name1_2', name: 'name1', sub_name: 'sub name1', api_version: 2, sla: 9.6, availabilities: availabilities.to_a }
        ]
      },
      {
        provider_name: 'provider2',
        endpoints_historicals: [
          { id: 'name2__2', name: 'name2', sub_name: nil, api_version: 2, sla: 9.6, availabilities: availabilities.to_a },
          { id: 'name3_sub_name3_1', name: 'name3', sub_name: 'sub name3', api_version: 1, sla: 9.6, availabilities: availabilities.to_a },
        ]
      },
     {
        provider_name: 'provider3',
        endpoints_historicals: [
          { id: 'name4_sub_name4_2', name: 'name4', sub_name: 'sub name4', api_version: 2, sla: 9.6, availabilities: availabilities.to_a }
        ]
      }
    ]
  end

  before do
    availabilities.add_history(1, datetime1)
    availabilities.add_history(1, datetime2)
    availabilities.add_history(1, datetime3)
    availabilities.add_history(0, datetime4)
    availabilities.add_history(0, datetime5)
    availabilities.add_history(0, datetime6)

    endpoint_historical_1.availabilities = availabilities
    endpoint_historical_2.availabilities = availabilities
    endpoint_historical_3.availabilities = availabilities
    endpoint_historical_4.availabilities = availabilities

    allow_any_instance_of(described_class).to receive(:providers_infos).and_return(providers_infos)
  end

  it 'returns a correctly formated JSON' do
    expect(json).to be_a(Array)
    expect(json.as_json).to include_json(expected_json)
  end
end
