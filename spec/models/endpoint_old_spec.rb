require 'rails_helper.rb'

describe EndpointOld, type: :model do
  context 'when happy path' do
    subject do
      described_class.new(
        name: name,
        sub_name: sub_name,
        provider: provider,
        api_version: api_version,
        api_name: api_name,
        period: period,
        parameter: parameter,
        options: options
      )
    end

    let(:name) { 'service name' }
    let(:sub_name) { 'sub name' }
    let(:provider) { 'provider name' }
    let(:api_version) { 2 }
    let(:api_name) { 'apie' }
    let(:period) { 5 }
    let(:parameter) { '00000' }
    let(:options) { 'options' }

    its(:id) { is_expected.to eq('service_name_sub_name_2') }
    its(:name) { is_expected.to eq(name) }
    its(:sub_name) { is_expected.to eq(sub_name) }
    its(:provider) { is_expected.to eq(provider) }
    its(:full_name) { is_expected.to eq("#{sub_name}/#{name}") }
    its(:api_version) { is_expected.to eq(api_version) }
    its(:api_name) { is_expected.to eq(api_name) }
    its(:period) { is_expected.to eq(period) }
    its(:parameter) { is_expected.to eq(parameter) }
    its(:options) { is_expected.to eq(options) }
    its(:valid?) { is_expected.to be_truthy }
  end

  context 'when is not valid' do
    subject(:endpoint) { described_class.new(api_version: 5, period: 12) }

    its(:valid?) { is_expected.to be_falsy }

    context 'when errors are expected' do
      subject { endpoint.errors.messages }

      before do
        endpoint.valid?
      end

      its([:name]) { is_expected.not_to be_empty }
      its([:provider]) { is_expected.not_to be_empty }
      its([:api_version]) { is_expected.not_to be_empty }
      its([:api_name]) { is_expected.not_to be_empty }
      its([:period]) { is_expected.not_to be_empty }
      its([:parameter]) { is_expected.not_to be_empty }
      its([:options]) { is_expected.not_to be_empty }
    end
  end
end
