class JwtPolicy
  attr_reader :user

  # Pundit is overkill here...
  # we only check jwt consistency no role check (yet?)
  def initialize(user, _policy)
    @user = user
  end
end
