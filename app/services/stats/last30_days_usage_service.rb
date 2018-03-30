require 'forwardable'

class Stats::Last30DaysUsageService
  extend Forwardable
  delegate %i[success? errors] => :@client

  attr_reader :results, :hits

  def initialize
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
    File.read('app/data/queries/last_30_days_usage.json')
  end

  def process_raw_response
    @hits = @client.raw_response # for spec
    @results = hits.dig('count') # no @ for spec
  end
end
