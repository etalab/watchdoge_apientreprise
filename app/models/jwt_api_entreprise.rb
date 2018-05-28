class JwtApiEntreprise
  attr_reader :uid, :jti, :roles

  def initialize(uid:, jti:, roles:, **)
    @uid = uid
    @jti = jti
    @roles = roles
  end
end
