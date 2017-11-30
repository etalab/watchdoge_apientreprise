class Dashboard::AvailabilityHistoryElastic < Dashboard::AbstractElastic
  def get
    process_query do
      get_raw_response 'availability_history'
      process_raw_availability_history
    end
  end

  private

  def process_raw_availability_history
    @endpoints_history = {}
    compute_all_availability_history_from_pings
    map_endpoints_to_providers
  end

  def map_endpoints_to_providers
    formater = Tools::EndpointsHistory::JSONFormater.new
    @values = formater.format_to_json(@endpoints_history)
  end

  def compute_all_availability_history_from_pings
    raw_datas = @raw_response.dig('hits', 'hits')

    raw_datas.each do |raw_data|
      parse raw_data['_source']

      create_or_update_hash_key
      add_availability
    end
  end

  def parse(raw_data)
    hash = ping_infos_from_elasticsearch raw_data

    @current_code = hash[:code] == 200 ? 1 : 0

    @current_timestamp = DateTime.parse(hash[:timestamp]).strftime('%F %T')

    @current_endpoint_history = EndpointHistory.new(
        name: hash[:name],
        sub_name: hash[:sub_name],
        api_version: hash[:api_version]
      )
  end

  def add_availability
    is_added = @current_endpoint_history.availabilities.add_history(
      @current_code,
      @current_timestamp
    )

    Rails.logger.error "Fail to add data (#{@current}) to availabilities" unless is_added
  end

  def create_or_update_hash_key
    if key_exists?
      replace_current_with_existing
    else
      add_new_key
    end
  end

  def key_exists?
    @endpoints_history.key?(@current_endpoint_history.id)
  end

  def add_new_key
    @endpoints_history[@current_endpoint_history.id] = @current_endpoint_history
  end

  def replace_current_with_existing
    @current_endpoint_history = @endpoints_history[@current_endpoint_history.id]
  end
end
