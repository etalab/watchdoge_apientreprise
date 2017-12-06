class Tools::EndpointsHistory::PingsAgregator
  def initialize(raw_datas)
    @raw_datas = raw_datas
  end

  def to_endpoints_history
    @endpoints_history = {}

    generate_history_from_pings

    @endpoints_history.values
  end

  private

  def generate_history_from_pings
    @raw_datas.each do |raw_data|
      parse raw_data['_source']

      create_or_update_hash_key
      add_ping
    end
  end

  def parse(source)
    @current = Tools::ElasticsearchSourceParser.parse source

    @current_endpoint_history = EndpointHistory.new(
      name: @current[:name],
      sub_name: @current[:sub_name],
      api_version: @current[:api_version]
    )
  end

  def create_or_update_hash_key
    if key_exists?
      replace_current_endpoint_with_existing
    else
      add_new_key
    end
  end

  def add_ping
    is_added = @current_endpoint_history.add_ping(
      current_code,
      current_timestamp
    )

    Rails.logger.error "Fail to add ping data (#{@current}) to availability_history" unless is_added
  end

  def key_exists?
    @endpoints_history.key?(@current_endpoint_history.id)
  end

  def add_new_key
    @endpoints_history[@current_endpoint_history.id] = @current_endpoint_history
  end

  def replace_current_endpoint_with_existing
    @current_endpoint_history = @endpoints_history[@current_endpoint_history.id]
  end

  def current_code
    @current[:code] == 200 ? 1 : 0
  end

  def current_timestamp
    Time.parse(@current[:timestamp]).strftime('%F %T')
  end
end
