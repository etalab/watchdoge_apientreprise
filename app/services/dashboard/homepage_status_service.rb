require 'forwardable'

class Dashboard::HomepageStatusService
  extend Forwardable
  delegate %i[success? errors] => :@client

  def initialize
    @client = ElasticClient.new
    @client.establish_connection
    @raw_results = []
  end

  def perform
    if @client.connected?
      @client.search json_query
      process_raw_response if @client.success?
    end

    self
  end

  # cf json_api_schemas: homepage_status.json
  def results
    @raw_results.as_json
  end

  private

  def json_query
    File.read('app/data/queries/homepage_status.json')
  end

  def process_raw_response
    raw_endpoint = @client.raw_response.dig('hits', 'hits', 0, '_source')
    endpoint = {
      'name': 'APIE Homepage',
      'code': raw_endpoint.dig('status'),
      'timestamp': raw_endpoint.dig('@timestamp')
    }

    @raw_results << endpoint
  end
end
