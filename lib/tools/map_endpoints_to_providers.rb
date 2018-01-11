class Tools::MapEndpointsToProviders
  def initialize(endpoints_history)
    @providers = {}
    @endpoints_history = endpoints_history
  end

  def to_json
    populate_json_result if @providers.empty?
    @providers.values
  end

  private

  def populate_json_result
    @endpoints_history.each do |endpoint_history|
      @current_eh = endpoint_history
      create_key unless key_exists?
      add_current_eh_to_result
    end
  end

  def create_key
    @providers[@current_eh.provider] = {
      provider_name: @current_eh.provider,
      endpoints_history: []
    }
  end

  def key_exists?
    @providers.key?(@current_eh.provider)
  end

  def add_current_eh_to_result
    @providers[@current_eh.provider][:endpoints_history] << endpoint_history_json
  end

  def endpoint_history_json
    {
      uname: @current_eh.uname,
      name: @current_eh.name,
      provider: @current_eh.provider,
      api_version: @current_eh.api_version,
      timezone: @current_eh.timezone,
      sla: @current_eh.sla,
      availability_history: @current_eh.availability_history.to_a
    }
  end
end
