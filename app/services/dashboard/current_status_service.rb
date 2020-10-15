require 'forwardable'

class Dashboard::CurrentStatusService
  extend Forwardable
  delegate %i[success? errors] => :@client

  def initialize
    @client = ElasticClient.new
    @client.establish_connection
    @endpoint_factory = EndpointFactory.new
    @raw_results = []
  end

  def perform
    if @client.connected?
      @client.search json_query
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
      source = raw_endpoint.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
      call_result = CallResult.new(source, @endpoint_factory)
      @raw_results << json_from_raw_endpoint(call_result) if call_result.valid?
    end
  end

  def raw_endpoints
    @client.raw_response.dig('aggregations', 'group_by_controller', 'buckets')
  end

  def json_from_raw_endpoint(call_result)
    {
      uname: call_result.uname,
      name: call_result.name,
      provider: call_result.provider,
      api_version: call_result.api_version,
      code: call_result.code,
      timestamp: call_result.timestamp,
      endpoint: call_result.controller
    }
  end
end
