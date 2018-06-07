require 'rails_helper'

describe JwtSessionUser do
  let(:jwt_payload) do
    {
      uid: '1e0f21cf-0d47-4594-89ae-172d0ac4001e',
      grants: [],
      admin: true,
      iat: 1_527_501_306,
      exp: 1_527_515_706
    }
  end

  describe '#initialize' do
    let(:admin) { false }

    it 'requires a uid keyword' do
      jwt_payload.delete(:uid)

      expect { described_class.new(jwt_payload) }.to raise_error ArgumentError
    end

    it 'requires a grants keyword' do
      jwt_payload.delete(:grants)

      expect { described_class.new(jwt_payload) }.to raise_error ArgumentError
    end
  end

  describe 'admin value' do
    subject { described_class.new(jwt_payload) }

    its(:admin?) { is_expected.to be_truthy }

    it 'is not admin' do
      jwt_payload.delete(:admin)

      expect(described_class.new(jwt_payload)).not_to be_admin
    end
  end

  describe 'respond to ?' do
    subject { described_class.new(jwt_payload) }

    it { is_expected.to respond_to(:uid) }
    it { is_expected.to respond_to(:admin?) }
    it { is_expected.to respond_to(:grants) }
  end
end
