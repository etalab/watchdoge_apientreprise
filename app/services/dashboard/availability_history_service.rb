require 'forwardable'

class Dashboard::AvailabilityHistoryService
  extend Forwardable
  delegate %i[success? errors] => :@client

  TIMEZONE = 'Europe/Paris'.freeze

  # for spec
  attr_reader :hits

  def initialize
    @client = Dashboard::ElasticClient.new
  end

  def perform
    retrieve_all_availabilities if success?
    process_raw_response if success?
    self
  end

  def results
    @results.as_json
  end

  private

  def retrieve_all_availabilities
    @hits = []
    loop do
      @client.perform json_query
      break unless success?
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
    @results = adapter.to_json_provider_list
  end

  def retrieved_hits
    @client.raw_response.dig('hits', 'hits')
  end

  def json_query
    query_hash.merge(search_after: @search_after).compact.to_json
  end

  def query_hash
    JSON.parse load_query(query_name)
  end

  def load_query(query_name)
    File.read(File.join('app', 'data', 'queries', query_name + '.json'))
  end

  def query_name
    'availability_history'
  end
end
