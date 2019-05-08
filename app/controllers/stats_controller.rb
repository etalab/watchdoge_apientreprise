class StatsController < ApplicationController
  def jwt_usage
    @success = true

    last_calls_service = Stats::LastCallsService.new jti: jti
    last_calls_service.perform
    @success &&= last_calls_service.success?

    usages = apis_usages

    if @success
      render json: { apis_usage: usages, last_calls: last_calls_service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end

  def last_30_days_usage
    service = Stats::LastApiUsageService.new(elk_time_range: '1M').tap(&:perform)

    if service.success?
      render json: service.results, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end

  def last_year_usage
    service = Stats::LastApiUsageService.new(elk_time_range: '1y').tap(&:perform)

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

  def apis_usage_service(elk_time_range)
    service  = Stats::ApisUsageService.new jti: jti, elk_time_range: elk_time_range
    service.perform
    @success &&= service.success?

    service
  end

  def apis_usages
    {
      "last_10_minutes": apis_usage_service('10m').results,
      "last_30_hours": apis_usage_service('30h').results,
      "last_8_days": apis_usage_service('8d').results
    }
  end
end
