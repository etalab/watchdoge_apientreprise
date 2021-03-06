require 'forwardable'

class Stats::ApisUsageService
  extend Forwardable
  delegate %i[success? errors] => :@client

  attr_reader :jti, :elk_time_range

  ApiUsage = Struct.new(:name, :total, :percent_success, :percent_not_found, :percent_other_client_errors, :percent_server_errors)

  def initialize(jti:, elk_time_range:)
    @jti = jti
    @elk_time_range = elk_time_range
    @client = ElasticClient.new
    @client.establish_connection
    @endpoint_factory = EndpointFactory.new
    @endpoints_usage = []
  end

  def perform
    if @client.connected?

      @client.search json_query
      process_raw_response if @client.success?
    end

    self
  end

  def results
    {
      total: total_hits,
      by_endpoint: @endpoints_usage
    }
  end

  private

  def process_raw_response
    retrieved_aggregations.each do |item|
      @current_api = item
      @endpoints_usage << current_api_usage.to_h
    end
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    @success = false
  end

  def current_api_usage
    ApiUsage.new(
      current_api_name,
      @current_api['doc_count'],
      current_percent_success,
      current_percent_not_found,
      current_percent_other_client_errors,
      current_percent_server_errors
    )
  end

  def current_percent_success
    get_percent_with(/^2\d{2}$/)
  end

  def current_percent_not_found
    get_percent_with(/^404$/)
  end

  def current_percent_other_client_errors
    get_percent_with(/^(?!404)4\d{2}$/)
  end

  def current_percent_server_errors
    get_percent_with(/^5\d{2}$/)
  end

  def get_percent_with(regexp)
    count_http_codes = count_http_codes_with regexp

    (count_http_codes / total_for_current_api * 100).round(1)
  end

  def count_http_codes_with(regexp)
    current_elements
      .select { |i| i['key'].to_s =~ regexp }
      .map    { |i| i['doc_count'] }
      .sum
      .to_f
  end

  def total_for_current_api
    @current_api['doc_count'].to_f
  end

  def current_elements
    @current_api['status-code']['buckets']
  end

  def current_api_name
    @current_api['key'].tr('_', ' ').capitalize
  end

  def retrieved_aggregations
    @client.raw_response['aggregations']['endpoints']['buckets']
  end

  def total_hits
    @client.raw_response['hits']['total']['value'].to_i
  end

  def json_query
    JSON.parse load_query
  end

  def load_query
    ERB.new(query_template).result(binding)
  end

  def query_template
    File.read('app/data/queries/' + query_name + '.json.erb')
  end

  # for specs
  def query_name
    'apis_usage'
  end
end
