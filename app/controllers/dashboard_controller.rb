class DashboardController < ApplicationController
  def current_status
    service = Dashboard::CurrentStatusElastic.new.get

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end

  def availability_history
    service = Dashboard::AvailabilityHistoryElastic.new.get

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end

  def homepage_status
    service = Dashboard::HomepageStatusElastic.new.get

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: 'an error occured' }, status: 500
    end
  end
end
