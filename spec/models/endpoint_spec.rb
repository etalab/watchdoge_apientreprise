describe Endpoint, type: :model do
  context 'happy path' do
    subject { described_class.new(name: name, api_version: api_version, parameter: parameter, options: options) }

    let(:name) { 'service name' }
    let(:api_version) { 2 }
    let(:parameter) { '00000' }
    let(:options) { 'options' }

    its(:name) { is_expected.to eq(name) }
    its(:api_version) { is_expected.to eq(api_version) }
    its(:parameter) { is_expected.to eq(parameter) }
    its(:options) { is_expected.to eq(options) }
    its(:valid?) { is_expected.to be_truthy }
  end

  context 'is not valid' do
    subject { described_class.new(api_version: 5) }

    its(:valid?) { is_expected.to be_falsy }

    context 'errors messages' do
      subject { described_class.new(api_version: 5).errors.messages }

      its([:name])        { is_expected.not_to be_nil }
      its([:api_version]) { is_expected.not_to be_nil }
      its([:parameter])   { is_expected.not_to be_nil }
      its([:options])     { is_expected.not_to be_nil }
    end
  end
end
