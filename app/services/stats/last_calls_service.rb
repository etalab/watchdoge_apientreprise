require 'forwardable'

class Stats::LastCallsService
  extend Forwardable
  delegate %i[success? errors] => :@client

  attr_reader :jti

  def initialize(jti:)
    @jti = jti
    @client = ElasticClient.new
    @client.establish_connection
    @endpoint_factory = EndpointFactory.new
    @last_calls = Stats::LastCalls.new
  end

  def perform
    return unless @client.connected?

    @client.search json_query
    process_raw_response if @client.success?
  end

  def results
    @last_calls.as_json
  end

  private

  def json_query
    JSON.parse erb_query
  end

  def erb_query
    ERB.new(query_template).result(binding)
  end

  def query_template
    File.read('app/data/queries/last_calls.json.erb')
  end

  def process_raw_response
    raw_last_calls.each do |data|
      call = CallResult.new(data['_source'], @endpoint_factory)
      next unless call.valid?

      @last_calls.add call
    end
  end

  def raw_last_calls
    @client.raw_response.dig('hits', 'hits')
  end
end
