shared_examples 'jwt policy' do |role, action = :show?|
  subject(:policy) { described_class }

  let(:jwt_user) { JwtUser.new(payload) }
  let(:payload) do
    {
      uid: 'db398baf-80c1-4d70-a2ce-87f5a097d636',
      jti: '96b35b36-38f3-436a-99a7-20dc6a88ab4d',
      roles: %w[rol1 rol2]
    }
  end

  permissions action do
    it 'authorizes a user with granted access' do
      payload.fetch(:roles).push(role.to_s)
      expect(policy).to permit(jwt_user)
    end

    it 'denies an unauthorized user' do
      expect(policy).not_to permit(jwt_user)
    end
  end
end
