require 'rails_helper'

describe EndpointAvailabilityHistory, type: :model do
  subject(:endpoint_history) do
    described_class.new(
      endpoint: endpoint,
      timezone: 'Asia/Jerusalem'
    )
  end

  let(:endpoint) { create(:endpoint) }

  before do
    endpoint_history.aggregate(1, '2017-10-10 10:10:10')
    endpoint_history.aggregate(0, '2017-10-12 10:10:10')
    endpoint_history.aggregate(1, '2017-10-14 10:10:10')
  end

  its(:uname) { is_expected.to eq('apie_2_certificats_test') }
  its(:name) { is_expected.to eq('Certificats Test') }
  its(:api_version) { is_expected.to eq(2) }
  its(:timezone) { is_expected.to eq('Asia/Jerusalem') }
  its(:provider) { is_expected.to eq('qualibat') }
  its(:sla) { is_expected.to eq(50) }
  its(:availability_history) { is_expected.not_to be_nil }
  its(:valid?) { is_expected.to be_truthy }

  # TODO: not a very good test...
  it 'converts timestamp to timezone before calling aggregate' do
    expect_any_instance_of(AvailabilityHistory).to receive(:aggregate).with(1, '2017-11-28 02:00:02').and_return(true)
    endpoint_history.aggregate(1, '2017-11-28T00:00:02.355Z')
  end
end
