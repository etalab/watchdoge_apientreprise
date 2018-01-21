require 'forwardable'

class Dashboard::AvailabilityHistoryService
  extend Forwardable
  delegate %i[success? errors] => :@client

  TIMEZONE = 'Europe/Paris'.freeze

  # for spec
  attr_reader :hits

  def initialize
    @hits = []
    @client = Dashboard::ElasticClient.new
    @client.establish_connection
  end

  def perform
    if @client.connected?
      retrieve_all_availabilities
      process_raw_response if @client.success?
    end

    self
  end

  # cf json_api_schemas: availability_history.json
  def results
    @raw_results.as_json
  end

  private

  def retrieve_all_availabilities
    loop do
      @client.perform json_query
      break unless @client.success?
      @hits.concat retrieved_hits
      @search_after = retrieved_hits.last['sort']
      break if retrieved_hits.count < 10_000
    end
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    @success = false
  end

  def process_raw_response
    aggregator = Tools::PingsAggregator.new(@hits, TIMEZONE)
    endpoints_availability_history = aggregator.endpoints_availability_history

    adapter = EndpointsAvailabilityAdapter.new(endpoints_availability_history)
    @raw_results = adapter.to_json_provider_list
  end

  def retrieved_hits
    @client.raw_response.dig('hits', 'hits')
  end

  def json_query
    query_hash.merge(search_after: @search_after).compact.to_json
  end

  def query_hash
    JSON.parse load_query
  end

  def load_query
    File.read('app/data/queries/' + query_name + '.json')
  end

  # for specs
  def query_name
    'availability_history'
  end
end
