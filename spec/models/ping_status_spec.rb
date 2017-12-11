require 'rails_helper.rb'

describe PingStatus, type: :model do
  context 'with happy path' do
    subject do
      described_class.new(
        name: name,
        url: url,
        http_response: http_response
      )
    end

    let(:name) { 'service name' }
    let(:url)  { 'https://www.test.com' }

    context 'when code 200' do
      let(:http_response) { Net::HTTPResponse.new(1.0, 200, 'OK') }

      its(:name) { is_expected.to eq(name) }
      its(:url) { is_expected.to eq(url) }
      its(:http_response) { is_expected.to eq(http_response) }
      its(:status) { is_expected.to eq('up') }
      its(:code) { is_expected.to eq(200) }
      its(:valid?) { is_expected.to be_truthy }
    end

    context 'when code 206' do
      let(:http_response) { Net::HTTPResponse.new(1.0, 206, 'OK') }

      its(:http_response) { is_expected.to eq(http_response) }
      its(:status) { is_expected.to eq('incomplete') }
      its(:code) { is_expected.to eq(206) }
    end

    context 'when code 400' do
      let(:http_response) { Net::HTTPResponse.new(1.0, 400, 'OK') }

      its(:http_response) { is_expected.to eq(http_response) }
      its(:status) { is_expected.to eq('down') }
      its(:code) { is_expected.to eq(400) }
    end
  end
end
