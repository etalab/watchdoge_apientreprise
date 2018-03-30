class StatsController < ApplicationController
  def jwt_usage
    service = Stats::JwtUsageService.new(jti: jti)
    service.perform

    if service.success?
      render json: service.results, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end

  def last_30_days_usage
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
