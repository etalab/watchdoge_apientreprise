require 'forwardable'

class Dashboard::CurrentStatusService
  extend Forwardable
  delegate %i[success? errors] => :@client

  def initialize
    @client = Dashboard::ElasticClient.new
    @values = []
  end

  def perform
    @client.perform json_query
    process_raw_response if success?
    self
  end

  def results
    @values.as_json
  end

  private

  def json_query
    File.read(File.join('app', 'data', 'queries', 'current_status.json'))
  end

  def process_raw_response
    raw_endpoints = @client.raw_response.dig('aggregations', 'group_by_controller', 'buckets')
    raw_endpoints.each do |e|
      source = e.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
      @values << ElasticsearchSource.new(source).to_json
    end
  end
end
