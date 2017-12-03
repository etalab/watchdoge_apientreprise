class Dashboard::AvailabilityHistoryElastic < Dashboard::AbstractElastic
  def get
    process_query do
      get_raw_response 'availability_history'
      process_raw_availability_history
    end
  end

  private

  def process_raw_availability_history
    generator = Tools::EndpointsHistory::Generator.new(@raw_response)
    endpoints_history = generator.to_endpoints_history

    mapper = Tools::EndpointsHistory::MapEndpointsToProviders.new(endpoints_history)
    @values = mapper.to_json
  end
end
