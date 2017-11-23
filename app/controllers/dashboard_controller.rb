class DashboardController < ApplicationController
  def current_status
    service = ElasticService.new.get_current_status

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end

  def availability_history
    service = ElasticService.new.get_availability_history

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end
end
