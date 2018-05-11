class StatsPolicy < JwtPolicy
  def admin_jwt_usage?
    user_authorised?
  end

  # it is not useless as it validate and build user from jwt
  def jwt_usage?
    true
  end

  protected

  def jwt_role
    'jwt_statistics'
  end
end
