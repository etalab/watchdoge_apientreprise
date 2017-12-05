class Dashboard::AvailabilityHistoryElastic < Dashboard::AbstractElastic
  def get
    get_all_availability_history
    process_raw_availability_history
    self
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_all_availability_history
    @hits = []
    loop do
      get_raw_response(query)
      retrieved_hits = @raw_response.dig('hits', 'hits')
      @hits.concat retrieved_hits
      @search_after = retrieved_hits.last['sort']
      break if retrieved_hits.count < 10_000
    end
  end

  private

  def process_raw_availability_history
    generator = Tools::EndpointsHistory::Generator.new(@hits)
    endpoints_history = generator.to_endpoints_history

    mapper = Tools::EndpointsHistory::MapEndpointsToProviders.new(endpoints_history)
    @values = mapper.to_json
  end

  def query
    query_hash.merge('search_after' => @search_after).compact.to_json
  end

  def query_hash
    JSON.parse load_query(query_name)
  end

  def query_name
    'availability_history'
  end
end
