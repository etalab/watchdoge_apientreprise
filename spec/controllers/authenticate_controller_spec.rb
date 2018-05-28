require 'rails_helper'

describe AuthenticateController do
  class FakePolicy < JwtPolicy
    def index?
      user_authorised?
    end

    def jwt_role
      'fake'
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
      request.headers['Authorization'] = "FuBearer #{JwtHelper.jwt(:fake_role)}"
      get :index
      assert_response 401
    end
  end

  context 'when jwt is passed in the header' do
    before { request.headers['Authorization'] = "Bearer #{token}" }

    context 'with a valid jwt' do
      let(:token) { JwtHelper.jwt(:fake_role) }

      it 'returns 200' do
        get :index
        assert_response 200
      end
    end

    context 'with a valid jwt but h&s not fake role' do
      let(:token) { JwtHelper.jwt(:valid) }

      it 'return 403' do
        get :index
        assert_response 403
      end
    end

    context 'with a invalid jwt' do
      let(:forged_jwt) { JwtHelper.jwt(:forged) }
      let(:user) { JwtService.new(jwt: forged_jwt).jwt_user }
      let(:token) { forged_jwt }

      it 'reutrns 401' do
        get :index
        assert_response 401
      end
    end

    context 'with a incorrect jwt' do
      let(:corrupted_jwt) { JwtHelper.jwt(:corrupted) }
      let(:user) { JwtService.new(jwt: corrupted_jwt).jwt_user }
      let(:token) { corrupted_jwt }

      it 'returns 401' do
        get :index
        assert_response 401
      end
    end
  end
end
