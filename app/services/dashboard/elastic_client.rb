class Dashboard::ElasticClient
  attr_reader :success, :raw_response, :errors
  alias success? success

  def initialize
    @errors = []
    @success = true
    initialize_client
  end

  def perform(json_query)
    try_to_perform(json_query) if errors.empty?
    self
  end

  private

  def try_to_perform(json_query)
    @raw_response = @client.search body: json_query
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    @errors << 'Elasticsearch BadRequest'
    @success = false
  end

  def initialize_client
    @client = Elasticsearch::Client.new host: 'watchdoge.entreprise.api.gouv.fr', log: false
    @client.transport.reload_connections!
  rescue Faraday::TimeoutError
    @errors << 'Timeout error, connection may not be allowed'
    @success = false
  end
end
