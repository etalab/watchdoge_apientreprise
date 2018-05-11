require 'rails_helper'

describe JwtTokenService do
  subject(:helper) { described_class.new(jwt: jwt) }

  context 'when created with a valid jwt' do
    let(:jwt) { JwtHelper.jwt(:valid) }

    its(:valid?) { is_expected.to be_truthy }
    its(:jwt_user) { is_expected.to be_a(JwtUser) }

    describe 'Jwt User' do
      subject { helper.jwt_user }

      its(:uid) { is_expected.to eq('1e0f21cf-0d47-4594-89ae-172d0ac4001e') }
      its(:jti) { is_expected.to eq('dd3149cc-5547-46aa-8f72-34bf63d8f7f8') }
    end
  end

  context 'when created with an invalid jwt' do
    let(:jwt) { 'not a valid jwt token' }

    its(:valid?) { is_expected.to be_falsey }
  end
end
