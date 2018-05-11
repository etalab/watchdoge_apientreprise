class JwtPolicy
  attr_reader :user

  def initialize(user, policy)
    @user = user
  end

  protected

  def user_authorised?
    user.has_access?(jwt_role)
  end

  def jwt_role
    fail 'to implement'
  end
end
