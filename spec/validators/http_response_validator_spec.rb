describe HTTPResponseValidator do
  class FakeHTTPResponse
    def initialize(body)
      @body = body
    end

    def body
      @body
    end
  end

  subject(:ping) do
    PingStatus.new(
      http_response: FakeHTTPResponse.new(fake_body)
    )
  end

  let(:validator) { described_class.new }

  describe 'happy path' do
    before do
      allow(validator).to receive(:expected_json_response).and_return(JSON.parse(fake_body))
    end

    let(:fake_body) { "{\"key\":\"value\"}" }

    it 'has no error' do
      validator.validate(ping)
      expect(ping.errors.count).to eq(0)
    end
  end

  describe 'failure path' do
    before do
      allow(validator).to receive(:expected_json_response).and_return(JSON.parse("{\"key\":\"value\"}"))
    end

    let(:fake_body) { 'not a json response' }

    it 'has one error' do
      validator.validate(ping)
      pending('dev not finished yet')
      expect(ping.errors.count).to eq(1)
    end
  end
end
