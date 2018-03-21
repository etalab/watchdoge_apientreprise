class Aggregators::JwtUsageAggregator
  attr_reader :number_of_calls, :last_calls, :http_code_percentages

  def initialize(raw_data:)
    @raw_data = raw_data
    @call_counter_aggregator = CallCounterAggregator.new
    # @last_calls = Stats::LastCalls.new
    # @http_code_percentages = Stats::HttpCodePercentages.new
    @endpoint_factory = EndpointFactory.new
  end

  def aggregate
    @raw_data.each do |data|
      call = CallCharacteristics.new(data['_source'], @endpoint_factory)
      @call_counter_aggregator.aggregate(call)
      # @last_calls.add(call)
      # @http_code_percentages.aggregate(call)
    end

    @raw_data.clear
  end
end