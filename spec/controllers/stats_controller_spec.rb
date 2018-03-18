require 'rails_helper'

describe StatsController, type: :controller do
  describe 'happy path', vcr: { cassette_name: 'jwt_usage' } do
    subject { get :jwt_usage, params: { jti: valid_jti } }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to match_json_schema('jwt_usage') }
  end

  describe 'happy path', vcr: { cassette_name: 'jwt_usage' } do
    subject { get :jwt_usage, params: { jti: valid_jti } }

    before { allow_any_instance_of(Stats::JwtUsageService).to receive(:success?).and_return(false) }

    its(:status) { is_expected.to eq(500) }
  end
end