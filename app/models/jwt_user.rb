class JwtUser
  attr_reader :uid, :jti

  def initialize(uid:, roles:, jti:, **)
    @uid = uid
    @roles = roles
    @jti = jti
  end

  def has_access?(role)
    @roles.include?(role)
  end
end