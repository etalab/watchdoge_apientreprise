require 'rails_helper'

describe JwtApiEntreprise, type: :jwt do
  let(:jwt_payload) do
    {
      uid: '398b0131-a660-4a03-8d04-d49d1f6e5e48',
      jti: '60b27e1a-54c2-4e15-926e-ec1459625bcb',
      roles: %w[
        etablissements
        entreprises
      ],
      sub: '',
      iat: 1_521_470_338
    }
  end

  describe '#initialize' do
    it 'requires uid keyword' do
      jwt_payload.delete(:uid)

      expect { described_class.new(jwt_payload) }.to raise_error ArgumentError
    end

    it 'requires jti keyword' do
      jwt_payload.delete(:jti)

      expect { described_class.new(jwt_payload) }.to raise_error ArgumentError
    end

    it 'requires roles keyword' do
      jwt_payload.delete(:roles)

      expect { described_class.new(jwt_payload) }.to raise_error ArgumentError
    end
  end

  describe 'respond to ?' do
    subject { described_class.new(jwt_payload) }

    it { is_expected.to respond_to(:uid) }
    it { is_expected.to respond_to(:jti) }
    it { is_expected.to respond_to(:roles) }
  end
end
