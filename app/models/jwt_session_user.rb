class JwtSessionUser
  attr_reader :uid, :admin, :grants

  alias admin? admin

  def initialize(uid:, grants:, **hash)
    @uid = uid
    @grants = grants
    @admin = hash.dig(:admin) || false
  end
end
