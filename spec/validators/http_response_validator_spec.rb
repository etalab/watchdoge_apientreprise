describe HTTPResponseValidator do
  class FakeHTTPResponse
    def initialize(body)
      @body = body
    end

    def body
      @body
    end
  end

  subject(:ping) { PingStatus.new(http_response: FakeHTTPResponse.new(fake_body)) }

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
      expect(ping.errors.count).to eq(1)
    end
  end

  describe 'regexp to test' do
    subject(:ping) { PingStatus.new(http_response: FakeHTTPResponse.new(body_with_regexp), response_regexp: response_regexp) }

    let(:expected_json) { "{\"valid_key\":\"my value\", \"regexp_key\":\"TESTsans72Regexp1743829\", \"another_regexp\":\"aaaBBB987654/TEST/.com\"}" }
    let(:response_regexp) { [ { 'name' => 'regexp_key', 'regexp' => '^TEST[a-z0-9]{6}Regexp\d{7}$'}, { 'name' => 'another_regexp', 'regexp' => '^a{3}B{3}\d{6}\/TEST\/\.com$' } ] }

    before do
      allow(validator).to receive(:expected_json_response).and_return(JSON.parse(expected_json))
    end

    context 'is valid body' do
      let(:body_with_regexp) { "{\"valid_key\":\"my value\", \"regexp_key\":\"TESTwith35Regexp5845489\", \"another_regexp\":\"aaaBBB123456/TEST/.com\"}" }

      it 'has not error' do
        validator.validate(ping)
        expect(ping.errors.count).to eq(0)
      end
    end

    context 'is invalid body' do
      let(:body_with_regexp) { "{\"valid_key\":\"my value\", \"regexp_key\":\"TESTwithaaa4435Regexp5845489\", \"another_regexp\":\"aaaBCBB123456/TEST/.com\"}" }

      it 'has an error' do
        validator.validate(ping)
        expect(ping.errors.count).to eq(1)
      end
    end
  end

end
