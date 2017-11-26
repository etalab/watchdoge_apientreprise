class DashboardController < ApplicationController
  def current_status
    service = CurrentStatusElastic.new.get

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end

  def availability_history
    service = AvailabilityHistoryElastic.new.get

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end

  def homepage_status
    service = HomepageStatusElastic.new.get

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end
end
