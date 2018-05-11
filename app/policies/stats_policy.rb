class StatsPolicy < JwtPolicy
  def jwt_usage?
    user_authorised?
  end

  protected

  def jwt_role
    'jwt_statistics'
  end
end
