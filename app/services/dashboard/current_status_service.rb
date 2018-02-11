require 'forwardable'

class Dashboard::CurrentStatusService
  extend Forwardable
  delegate %i[success? errors] => :@client

  def initialize
    @client = Dashboard::ElasticClient.new
    @client.establish_connection
    @endpoint_factory = EndpointFactory.new
    @raw_results = []
  end

  def perform
    if @client.connected?
      @client.perform json_query
      process_raw_response if @client.success?
    end

    self
  end

  # cf json_api_schemas: current_status.json
  def results
    @raw_results.as_json
  end

  private

  def json_query
    File.read('app/data/queries/current_status.json')
  end

  def process_raw_response
    raw_endpoints.each do |raw_endpoint|
      @raw_results << json_from_raw_endpoint(raw_endpoint)
    end
  end

  def raw_endpoints
    @client.raw_response.dig('aggregations', 'group_by_controller', 'buckets')
  end

  def json_from_raw_endpoint(raw_endpoint)
    source = raw_endpoint.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
    endpoint_ping = EndpointPingResult.new(@endpoint_factory, source)
    {
      uname: endpoint_ping.uname,
      name: endpoint_ping.name,
      provider: endpoint_ping.provider,
      api_version: endpoint_ping.api_version,
      code: endpoint_ping.code,
      timestamp: endpoint_ping.timestamp
    }
  end
end
