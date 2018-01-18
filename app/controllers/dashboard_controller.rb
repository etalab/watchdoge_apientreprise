class DashboardController < ApplicationController
  class << self
    def expose_services_status(*status_service_classes)
      status_service_classes.each do |status_service_class|
        expose_service_status(status_service_class)
      end
    end

    def expose_service_status(status_service_class)
      method_name = status_service_class.name.split('::').last.sub('Service','').underscore

      define_method(method_name) do
        service = status_service_class.new.perform

        if service.success?
          render json: { results: service.results }, status: 200
        else
          render json: { message: service.errors.join(',') }, status: 500
        end
      end
    end
  end

  expose_services_status  Dashboard::CurrentStatusService,
                          Dashboard::AvailabilityHistoryService,
                          Dashboard::HomepageStatusService
end
