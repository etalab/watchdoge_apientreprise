class JwtUsageAggregator
  def initialize(raw_data:)
    @raw_data = raw_data
    @call_counter_aggregator = CallCounterAggregator.new
    @http_code_percentages_aggregator = HttpCodePercentagesAggregator.new
    @last_calls = Stats::LastCalls.new
    @endpoint_factory = EndpointFactory.new
  end

  def aggregate
    @raw_data.each do |data|
      call = CallCharacteristics.new(data['_source'], @endpoint_factory)
      @call_counter_aggregator.aggregate(call)
      @http_code_percentages_aggregator.aggregate(call)
      @last_calls.add(call)
    end

    @raw_data.clear
  end

  def number_of_calls
    @call_counter_aggregator.as_json
  end

  def last_calls
    @last_calls.as_json
  end

  def http_code_percentages
    @http_code_percentages_aggregator.as_json
  end
end
