class Aggregators::JwtUsageAggregator
  attr_reader :number_of_calls, :last_calls, :http_code_percentages

  def initialize(raw_data:)
    @raw_data = raw_data
    @number_of_calls = Stats::NumberOfCalls.new
    @last_calls = Stats::LastCalls.new
    @http_code_percentages = Stats::HttpCodePercentages.new
    @endpoint_factory = EndpointFactory.new
  end

  def aggregate
    @raw_data.each do |data|
      ping_result = CallCharacteristics.new(data['_source'], @endpoint_factory)
      @number_of_calls.aggregate(ping_result)
      @last_calls.aggregate(ping_result)
      @http_code_percentages.aggregate(ping_result)
    end

    @raw_data.clear
  end
end