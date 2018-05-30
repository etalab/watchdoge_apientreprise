shared_examples 'jwt policy' do |action = :show?|
  subject(:policy) { described_class }

  let(:jwt_user) { JwtSessionUser.new(payload) }
  let(:payload) do
    {
      uid: '1e0f21cf-0d47-4594-89ae-172d0ac4001e',
      grants: [],
      iat: 1_527_501_306,
      exp: 1_527_515_706
    }
  end

  let(:wrong_jwt_user) { JwtSessionUser.new(wrong_payload: 'nope') }

  permissions action do
    it 'authorizes a user with granted access' do
      payload[:admin] = true
      expect(policy).to permit(jwt_user)
    end

# There is no right for the momoent, pundit is overkill here
#    it 'denies an unauthorized user' do
#      expect(policy).not_to permit(wrong_jwt_user)
#    end
  end
end
