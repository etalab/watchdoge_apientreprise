require 'forwardable'

class Stats::LastApiUsageService
  extend Forwardable
  delegate %i[success? errors] => :@client

  attr_reader :results, :hits, :elk_time_range

  def initialize(elk_time_range: '1M')
    @elk_time_range = elk_time_range
    @client = ElasticClient.new
    @client.establish_connection
  end

  def perform
    return unless @client.connected?

    @client.count json_query
    process_raw_response if @client.success?
  end

  private

  def json_query
    JSON.parse erb_query
  end

  def erb_query
    ERB.new(query_template).result(binding)
  end

  def query_template
    File.read('app/data/queries/last_api_usage.json.erb')
  end

  def process_raw_response
    @hits = @client.raw_response # for spec
    @results = hits.dig('count') # no @ for spec
  end
end
