class StatsController < AuthenticateController
  def admin_jwt_usage
    authorize :stats

    render_jwt_usage param_jti
  end

  def jwt_usage
    authorize :stats

    render_jwt_usage user.jti
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

  def param_jti
    params.permit(:jti)['jti']
  end
end
