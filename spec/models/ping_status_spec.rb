require 'rails_helper.rb'

describe PingStatus, type: :model do
  context 'happy path' do
    subject(:ping) do
      described_class.new(
        name: name,
        url: url,
        http_response: http_response
      )
    end

    let(:name) { 'service name' }
    let(:url)  { 'https://www.test.com' }

    context 'code 200' do
      let(:http_response) { Net::HTTPResponse.new(1.0, 200, 'OK') }

      its(:name) { is_expected.to eq(name) }
      its(:url) { is_expected.to eq(url) }
      its(:http_response) { is_expected.to eq(http_response) }
      its(:status) { is_expected.to eq('up') }
      its(:valid?) { is_expected.to be_truthy }
    end

    context 'code 206' do
      let(:http_response) { Net::HTTPResponse.new(1.0, 206, 'OK') }

      its(:http_response) { is_expected.to eq(http_response) }
      its(:status) { is_expected.to eq('incomplete') }
    end

    context 'code 400' do
      let(:http_response) { Net::HTTPResponse.new(1.0, 400, 'OK') }

      its(:http_response) { is_expected.to eq(http_response) }
      its(:status) { is_expected.to eq('down') }
    end
  end
end
