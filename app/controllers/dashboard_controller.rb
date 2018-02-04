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
        service = service_class.new.perform

        if service.success?
          render json: { results: service.results }, status: 200
        else
          render json: { message: service.errors.join(',') }, status: 500
        end
      end
    end
  end

  expose_services Dashboard::CurrentStatusService,
                  Dashboard::AvailabilityHistoryService,
                  Dashboard::HomepageStatusService
end
