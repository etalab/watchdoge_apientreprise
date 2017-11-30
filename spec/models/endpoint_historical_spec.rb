require 'rails_helper.rb'

describe EndpointHistorical, type: :model do
  subject do
    described_class.new(
      name: 'test Oki',
      sub_name: 'Sub name',
      api_version: 2,
      provider: 'provider'
    )
  end

  before do
    subject.availabilities.add_history(1, '2017-10-10 10:10:10')
    subject.availabilities.add_history(0, '2017-10-12 10:10:10')
    subject.availabilities.add_history(1, '2017-10-14 10:10:10')
  end

  its(:id) { is_expected.to eq('test_oki_sub_name_2') }
  its(:name) { is_expected.not_to be_nil }
  its(:api_version) { is_expected.to be_a(Integer) }
  its(:provider) { is_expected.to eq('provider') }
  its(:sla) { is_expected.to eq(99.98) }
  its(:availabilities) { is_expected.not_to be_nil }
end
