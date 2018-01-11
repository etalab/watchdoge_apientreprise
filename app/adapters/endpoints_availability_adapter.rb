class EndpointsAvailabilityAdapter
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
      @current_eah = endpoint_avail_history
      create_key unless key_exists?
      add_current_eh_to_result
    end
  end

  def create_key
    @providers[@current_eah.provider] = {
      provider_name: @current_eah.provider,
      endpoints_availability_history: []
    }
  end

  def key_exists?
    @providers.key?(@current_eah.provider)
  end

  def add_current_eh_to_result
    @providers[@current_eah.provider][:endpoints_availability_history] << endpoint_history_json
  end

  def endpoint_history_json
    {
      uname: @current_eah.uname,
      name: @current_eah.name,
      provider: @current_eah.provider,
      api_version: @current_eah.api_version,
      timezone: @current_eah.timezone,
      sla: @current_eah.sla,
      availability_history: @current_eah.availability_history.to_a
    }
  end
end
