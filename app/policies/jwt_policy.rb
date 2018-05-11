class JwtPolicy
  attr_reader :user

  def initialize(user, _policy)
    @user = user
  end

  protected

  def user_authorised?
    user.access?(jwt_role)
  end

  def jwt_role
    raise 'to implement'
  end
end
