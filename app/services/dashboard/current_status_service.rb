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
    File.read('app/data/queries/current_status.json')
  end

  def process_raw_response
    raw_endpoints.each do |raw_endpoint|
      @results << json_from_raw_endpoint(raw_endpoint)
    end
  end

  def raw_endpoints
    @client.raw_response.dig('aggregations', 'group_by_controller', 'buckets')
  end

  def json_from_raw_endpoint(raw_endpoint)
    source = raw_endpoint.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
    ElasticsearchSource.new(source).to_json
  end
end
