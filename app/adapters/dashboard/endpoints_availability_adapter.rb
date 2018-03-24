class Dashboard::EndpointsAvailabilityAdapter
  def initialize(avail_history)
    @providers = {}
    @endpoints_avail_history = avail_history
  end

  # cf json_api_schemas: availability_history.json
  def to_json_provider_list
    populate_json_result if @providers.empty?
    @providers.values
  end

  private

  def populate_json_result
    @endpoints_avail_history.each do |endpoint_avail_history|
      @current_avail_history = endpoint_avail_history
      create_key unless key_exists?
      add_current_eh_to_result
    end
  end

  def create_key
    @providers[current_provider] = {
      provider_name: current_provider,
      endpoints_availability_history: []
    }
  end

  def key_exists?
    @providers.key?(current_provider)
  end

  def add_current_eh_to_result
    @providers[current_provider][:endpoints_availability_history] << new_json_endpoint_history
  end

  def new_json_endpoint_history
    {
      uname: @current_avail_history.uname,
      name: @current_avail_history.name,
      provider: current_provider,
      api_version: @current_avail_history.api_version,
      timezone: @current_avail_history.timezone,
      provider_name: @current_avail_history.provider_name,
      sla: @current_avail_history.sla,
      availability_history: @current_avail_history.availability_history.to_a
    }
  end

  def current_provider
    @current_avail_history.provider
  end
end
