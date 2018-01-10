require 'rails_helper'

describe EndpointHistory, type: :model do
  subject(:endpoint_history) do
    described_class.new(
      name: 'test Oki',
      sub_name: 'Sub name',
      api_version: 2,
      timezone: 'Asia/Jerusalem',
      provider: 'provider'
    )
  end

  before do
    endpoint_history.add_ping(1, '2017-10-10 10:10:10')
    endpoint_history.add_ping(0, '2017-10-12 10:10:10')
    endpoint_history.add_ping(1, '2017-10-14 10:10:10')
  end

  its(:id) { is_expected.to eq('test_oki_sub_name_2') }
  its(:name) { is_expected.not_to be_nil }
  its(:api_version) { is_expected.to be_a(Integer) }
  its(:timezone) { is_expected.to eq('Asia/Jerusalem') }
  its(:provider) { is_expected.to eq('provider') }
  its(:sla) { is_expected.to eq(50) }
  its(:availability_history) { is_expected.not_to be_nil }

  # TODO: not a very good test...
  it 'converts timestamp to timezone before calling add_ping' do
    expect_any_instance_of(AvailabilityHistory).to receive(:add_ping).with(1, '2017-11-28 02:00:02').and_return(true)
    endpoint_history.add_ping(1, '2017-11-28T00:00:02.355Z')
  end
end
