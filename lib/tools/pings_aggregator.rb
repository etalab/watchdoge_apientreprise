class Tools::PingsAggregator
  def initialize(raw_data, timezone)
    @raw_data = raw_data
    @timezone = timezone
    @sources = []
    @endpoints_availability_history = {}
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
      source = ElasticsearchSource.new(data['_source'])
      @sources << source
    end

    @raw_data.clear # 15Mo here...
  end

  def fill_history_with_pings
    @sources.each do |source|
      @current = source
      create_key unless key_exists?
      aggregate_current_status
    end
  end

  def create_key
    @endpoints_availability_history[@current.uname] = current_endpoint_history
  end

  def current_endpoint_history
    EndpointAvailabilityHistory.new(
      endpoint: @current.endpoint,
      timezone: @timezone
    )
  end

  def aggregate_current_status
    is_aggregated = @endpoints_availability_history[@current.uname].aggregate(
      current_code,
      current_timestamp
    )

    Rails.logger.error "Fail to add ping data (#{@current}) to availability_history" unless is_aggregated
  end

  def key_exists?
    @endpoints_availability_history.key?(@current.uname)
  end

  def current_code
    @current.code == 200 ? 1 : 0
  end

  def current_timestamp
    @current.timestamp
  end
end
