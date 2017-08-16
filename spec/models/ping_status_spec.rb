describe PingStatus, type: :model do
  context 'happy path' do
    subject(:ping) do
      described_class.new(
        name: name,
        http_response: http_response
      )
    end

    let(:name) { 'service name' }
    let(:http_response) { Net::HTTPResponse.new(1.0, 200, 'OK') }

    its(:name) { is_expected.to eq(name) }
    its(:http_response) { is_expected.to eq(http_response) }
    its(:valid?) { is_expected.to be_truthy }
  end
end
