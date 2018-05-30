class StatsPolicy < JwtPolicy
  # it is not useless as it validates and build user from jwt
  def jwt_usage?
    true
  end
end
