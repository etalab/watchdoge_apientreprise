require 'rails_helper'

describe AuthenticateController do
  class FakePolicy < JwtPolicy
    def index?
      true
    end
  end

  controller(described_class) do
    def index
      authorize :fake
      render json: {}, status: 200
    end
  end

  context 'without valid token' do
    it 'returns 401 when token is missing' do
      get :index
      assert_response 401
    end

    it 'returns 401 with bad header token' do
      request.headers['Authorization'] = 'Bearer bad_token'
      get :index
      assert_response 401
    end

    it 'returns 401 with bad header naming' do
      request.headers['Authorization'] = "FuBearer #{JwtHelper.session(:valid)}"
      get :index
      assert_response 401
    end
  end

  context 'when jwt is passed in the header' do
    before { request.headers['Authorization'] = "Bearer #{jwt_session}" }

    context 'with a valid jwt' do
      let(:jwt_session) { JwtHelper.session(:valid) }

      it 'returns 200' do
        get :index
        assert_response 200
      end
    end

    shared_examples 'invalid jwt' do |jwt|
      let(:jwt_session) { jwt }

      it 'returns 401' do
        get :index
        assert_response 401
      end
    end

    it_behaves_like 'invalid jwt', JwtHelper.session(:expired)
    it_behaves_like 'invalid jwt', JwtHelper.session(:forged)
    it_behaves_like 'invalid jwt', JwtHelper.session(:corrupted)
  end
end
