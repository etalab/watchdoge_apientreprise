class DashboardController < ApplicationController
  def current_status
    service = Dashboard::CurrentStatusService.new.perform

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end

  def availability_history
    service = Dashboard::AvailabilityHistoryService.new.perform

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end

  def homepage_status
    service = Dashboard::HomepageStatusService.new.perform

    if service.success?
      render json: { results: service.results }, status: 200
    else
      render json: { message: service.errors.join(',') }, status: 500
    end
  end
end
