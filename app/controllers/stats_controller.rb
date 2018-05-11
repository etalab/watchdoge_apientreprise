class StatsController < AuthenticateController
  def jwt_usage
    authorize :stats

    raise UnauthorizedError if pundit_user.jti != jti

    service = Stats::JwtUsageService.new(jti: jti)
    service.perform

    if service.success?
      render json: service.results, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
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

  def jti
    params.permit(:jti)['jti']
  end
end
