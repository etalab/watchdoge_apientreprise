class Dashboard::PingHistoryAggregator
  def initialize(raw_data, timezone)
    @raw_data = raw_data
    @timezone = timezone
    @elk_sources = []
    @endpoints_availability_history = {}
    @endpoint_factory = EndpointFactory.new
  end

  def endpoints_availability_history
    if @endpoints_availability_history.empty?
      parse_raw_data_into_sources
      fill_history_with_pings
    end
    @endpoints_availability_history.values
  end

  private

  def parse_raw_data_into_sources
    @raw_data.each do |data|
      elk_source = CallResult.new(data['_source'], @endpoint_factory)
      @elk_sources << elk_source
    end

    @raw_data.clear # 15Mo here...
  end

  def fill_history_with_pings
    @elk_sources.each do |elk_source|
      @current_elk_source = elk_source
      create_key unless key_exists?
      aggregate_current_http_code
    end
  end

  def create_key
    @endpoints_availability_history[@current_elk_source.uname] = new_endpoint_avail_history
  end

  def new_endpoint_avail_history
    Dashboard::EndpointAvailabilityHistory.new(
      endpoint: @current_elk_source.endpoint,
      timezone: @timezone,
      provider_name: @current_elk_source.provider_name
    )
  end

  def aggregate_current_http_code
    is_aggregated = current_endpoint_avail_history.aggregate(current_http_code, current_timestamp)

    Rails.logger.error "Fail to add ping data (#{@current_elk_source}) to availability_history" unless is_aggregated
  end

  def key_exists?
    @endpoints_availability_history.key?(@current_elk_source.uname)
  end

  def current_endpoint_avail_history
    @endpoints_availability_history[@current_elk_source.uname]
  end

  def current_timestamp
    @current_elk_source.timestamp
  end

  def current_http_code
    if up? && fallback_used?
      212
    elsif down? && fallback_used?
      512
    elsif down?
      500
    else
      @current_elk_source.code
    end
  end

  def up?
    [200, 206].include?(@current_elk_source.code)
  end

  def down?
    !up?
  end

  def fallback_used?
    @current_elk_source.fallback_used
  end
end
