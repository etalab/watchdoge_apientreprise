require 'forwardable'

class Dashboard::CurrentStatusService
  extend Forwardable
  delegate %i[success? errors] => :@client

  def initialize
    @client = Dashboard::ElasticClient.new
    @results = []
  end

  def perform
    @client.perform json_query
    process_raw_response if success?
    self
  end

  # cf json_api_schemas: current_status.json
  def results
    @results.as_json
  end

  private

  def json_query
    File.read(File.join('app', 'data', 'queries', 'current_status.json'))
  end

  def process_raw_response
    raw_endpoints = @client.raw_response.dig('aggregations', 'group_by_controller', 'buckets')
    raw_endpoints.each do |e|
      source = e.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
      @results << ElasticsearchSource.new(source).to_json
    end
  end
end
