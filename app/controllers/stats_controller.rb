class StatsController < AuthenticateController
  def jwt_usage
    authorize :stats

    if !valid_jwt?
      render json: { message: 'invalid jwt param' }, status: 422
    elsif user.admin? || jwt_of_user?
      render_jwt_usage param_jwt.jti
    else
      render json: { message: 'Cannot display someone else jwt usage without being an admin' }, status: 403
    end
  end

  def last_30_days_usage
    skip_authorization

    service = Stats::Last30DaysUsageService.new.tap(&:perform)

    if service.success?
      render json: service.results, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end

  private

  def render_jwt_usage(jti)
    service = Stats::JwtUsageService.new(jti: jti)
    service.perform

    if service.success?
      render json: service.results, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end

  def valid_jwt?
    !param_jwt.nil?
  end

  def jwt_of_user?
    user.uid == param_jwt.uid
  end

  def param_jwt
    @param_jwt ||= JwtService.new(
      jwt: params.permit('jwt')['jwt']
    ).jwt_api_entreprise
  end
end
