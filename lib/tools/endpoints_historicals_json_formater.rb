class Tools::EndpointsHistoricalsJSONFormater
  def format_to_json(endpoints_historicals)
    @json_result = {}
    @endpoints_historicals = endpoints_historicals

    populate_json_result

    @json_result.values
  end

  private

  def populate_json_result
    @endpoints_historicals.each do |key, value|
      @current_eh = value
      add_provider_to_endpoint_historical
      if provider_key_exists?
        update_json
      else
        create_json
      end
    end
  end

  def add_provider_to_endpoint_historical
    providers_infos.each do |key, value|
      if value[:endpoints_ids].include?(@current_eh.id)
        @current_eh.provider = value[:name]
        break
      end
    end

    if @current_eh.provider.nil?
      Rails.logger.error "Fail to map Elasticsearch result to a provider: #{@current_eh}"
    end
  end

  def provider_key_exists?
    @json_result.key?(@current_eh.provider)
  end

  def update_json
    @json_result[@current_eh.provider][:endpoints_historicals] << endpoint_historical_json
  end

  def create_json
    @json_result[@current_eh.provider] = {
      provider_name: @current_eh.provider,
      endpoints_historicals: [endpoint_historical_json]
    }
  end

  def endpoint_historical_json
    {
      id: @current_eh.id,
      name: @current_eh.name,
      sub_name: @current_eh.sub_name,
      api_version: @current_eh.api_version,
      sla: @current_eh.sla,
      availabilities: @current_eh.availabilities.to_a
    }
  end

  def providers_infos
    Tools::EndpointFactory.new('apie').providers_infos
  end
end
