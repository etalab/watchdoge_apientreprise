class Stats::JwtUsageAggregator
  def initialize(raw_data:)
    @raw_data = raw_data
    @apis_usage_aggregator = Stats::ApisUsageAggregator.new
    @last_calls = Stats::LastCalls.new
    @endpoint_factory = EndpointFactory.new
  end

  def aggregate
    @raw_data.each do |data|
      call = CallResult.new(data['_source'], @endpoint_factory)
      next unless call.valid?

      @apis_usage_aggregator.aggregate(call)
      @last_calls.add(call)
    end

    @raw_data.clear
  end

  def last_calls
    @last_calls.as_json
  end

  def apis_usage
    @apis_usage_aggregator.as_json
  end
end
