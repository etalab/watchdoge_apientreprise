require 'rails_helper'

describe JwtService do
  subject(:service) { described_class.new(jwt: jwt) }

  context 'when creating a valid API jwt' do
    let(:jwt) { JwtHelper.api(:valid) }

    its(:valid?) { is_expected.to be_truthy }
    its(:jwt_api_entreprise) { is_expected.to be_a(JwtApiEntreprise) }
    its(:jwt_user) { is_expected.to be_nil }

    describe 'Jwt API Entreprise' do
      subject { service.jwt_api_entreprise }

      its(:uid) { is_expected.to eq('eef0b01d-00c9-49a3-ab8c-3f77700e3bd2') }
      its(:jti) { is_expected.to eq('a40b2c1f-19aa-48df-8bb3-c5a316cae2f8') }
    end
  end

  context 'when creating a valid SESSION jwt' do
    let(:jwt) { JwtHelper.session(:valid) }

    its(:valid?) { is_expected.to be_truthy }
    its(:jwt_api_entreprise) { is_expected.to be_nil }
    its(:jwt_user) { is_expected.to be_a(JwtSessionUser) }

    describe 'Jwt User' do
      subject { service.jwt_user }

      its(:uid) { is_expected.to eq('eef0b01d-00c9-49a3-ab8c-3f77700e3bd2') }
      its(:admin) { is_expected.to be_falsey }
      its(:grants) { is_expected.to be_empty }
    end
  end

  context 'when created with an expired jwt' do
    let(:jwt) { JwtHelper.session(:expired) }

    its(:valid?) { is_expected.to be_truthy }
    its(:jwt_user) { is_expected.to be_nil }
  end

  context 'when created with an invalid jwt' do
    let(:jwt) { 'not a valid jwt token' }

    its(:valid?) { is_expected.to be_falsey }
  end
end
