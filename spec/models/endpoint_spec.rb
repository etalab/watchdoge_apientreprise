describe Endpoint, type: :model do
  context 'happy path' do
    let(:name) { 'service name' }
    let(:api_version) { 2 }
    let(:parameter) { '00000' }
    let(:options) { 'options' }

    subject { described_class.new(name: name, api_version: api_version, parameter: parameter, options: options) }

    its(:name) { is_expected.to eq(name) }
    its(:api_version) { is_expected.to eq(api_version) }
    its(:parameter) { is_expected.to eq(parameter) }
    its(:options) { is_expected.to eq(options) }
    its(:valid?) { is_expected.to be_truthy }

    context 'is not valid' do
      describe 'invalid data' do
        subject { described_class.new({api_version: 5}) }

        it 'contains specifics errors' do
          expect(subject.valid?).to be_falsy
          json = subject.errors.messages
          expect(json[:name]).not_to        be_nil
          expect(json[:api_version]).not_to be_nil
          expect(json[:parameter]).not_to   be_nil
          expect(json[:options]).not_to     be_nil
        end
      end
    end
  end
end
