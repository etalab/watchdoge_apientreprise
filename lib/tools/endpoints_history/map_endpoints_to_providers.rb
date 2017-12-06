class Tools::EndpointsHistory::MapEndpointsToProviders
  def initialize(endpoints_history)
    @endpoints_history = endpoints_history
  end

  def to_json
    @json_result = {}

    populate_json_result

    @json_result.values
  end

  private

  def populate_json_result
    @endpoints_history.each do |eh|
      @current_eh = eh

      add_provider_to_endpoint_history
      create_or_update_hash_key
    end
  end

  def create_or_update_hash_key
    if provider_key_exists?
      update_json
    else
      create_json
    end
  end

  def add_provider_to_endpoint_history
    providers_infos.each_value do |value|
      if value[:endpoints_ids].include?(@current_eh.id)
        @current_eh.provider = value[:name]
        break
      end
    end

    log_error if @current_eh.provider.nil?
  end

  def log_error
    Rails.logger.error "Fail to map Elasticsearch result to a provider: #{@current_eh}"
  end

  def provider_key_exists?
    @json_result.key?(@current_eh.provider)
  end

  def update_json
    @json_result[@current_eh.provider][:endpoints_history] << endpoint_history_json
  end

  def create_json
    @json_result[@current_eh.provider] = {
      provider_name: @current_eh.provider,
      endpoints_history: [endpoint_history_json]
    }
  end

  def endpoint_history_json
    {
      id: @current_eh.id,
      name: @current_eh.name,
      sub_name: @current_eh.sub_name,
      api_version: @current_eh.api_version,
      sla: @current_eh.sla,
      availability_history: @current_eh.availability_history.to_a
    }
  end

  def providers_infos
    Tools::EndpointFactory.new('apie').providers_infos
  end
end
