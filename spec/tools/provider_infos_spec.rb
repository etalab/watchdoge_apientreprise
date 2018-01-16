require 'rails_helper'

describe Tools::ProviderInfos do
  subject(:provider_infos) { described_class.instance }

  it { is_expected.to be_a_kind_of(described_class) }

  # Json schema can't check uniqueness
  its(:all) { is_expected.to match_json_schema('provider_infos_list') }

  it 'has uniq elemets' do
    size = provider_infos.all.map { |p| p[:uname] }.size
    expect(size).to eq(15)
  end

  it 'has providers infos all composed of uniq endpoints' do
    provider_infos.all.each do |p|
      expect(p[:endpoints_unames].size).to eq(p[:endpoints_unames].uniq.size)
    end
  end
end
