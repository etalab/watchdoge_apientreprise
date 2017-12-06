class Dashboard::AvailabilityHistoryElastic < Dashboard::AbstractElastic
  def get
    get_all_availability_history
    process_raw_availability_history if success?
    self
  end

  private

  # rubocop:disable Naming/AccessorMethodName
  def get_all_availability_history
    @hits = []
    loop do
      get_raw_response(query)
      break unless success?
      @hits.concat retrieved_hits
      @search_after = retrieved_hits.last['sort']
      break if retrieved_hits.count < 10_000
    end
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    @success = false
  end

  def process_raw_availability_history
    agregator = Tools::EndpointsHistory::PingsAgregator.new(@hits)
    endpoints_history = agregator.to_endpoints_history

    mapper = Tools::EndpointsHistory::MapEndpointsToProviders.new(endpoints_history)
    @values = mapper.to_json
  end

  def hits # for spec
    @hits
  end

  def retrieved_hits
    @raw_response.dig('hits', 'hits')
  end

  def query
    query_hash.merge(search_after: @search_after).compact.to_json
  end

  def query_hash
    JSON.parse load_query(query_name)
  end

  def query_name
    'availability_history'
  end
end
