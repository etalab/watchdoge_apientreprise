class DashboardController < ApplicationController
  class << self
    def expose_services(*service_classes)
      service_classes.each do |service_class|
        expose_service(service_class)
      end
    end

    def expose_service(service_class)
      method_name = service_class.name.split('::').last.sub('Service', '').underscore

      define_method(method_name) do
        service = perform_with_cache(service_class)

        if service[:success]
          render json: { results: service[:results] }, status: 200
        else
          render json: { message: service[:errors] }, status: 500
        end
      end
    end
  end

  expose_services Dashboard::CurrentStatusService,
                  Dashboard::AvailabilityHistoryService,
                  Dashboard::HomepageStatusService

  private

  def perform_with_cache(service_class)
    Rails.cache.fetch(service_class.to_s, expires_in: 5.minutes) do
      service = service_class.new.perform

      {
        success: service.success?,
        results: service.results,
        errors: service.errors.join(',')
      }
    end
  end
end
