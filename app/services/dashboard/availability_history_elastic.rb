class Dashboard::AvailabilityHistoryElastic < Dashboard::AbstractElastic
  attr_accessor :hits

  def initialize
    super
    @hits = []
  end

  def get
    get_all_availability_history
    process_raw_availability_history
    self
  end

  def get_all_availability_history
    loop do
      retrieved_hits = AllAvailabilityHistory.new(@search_after).execute.dig('hits', 'hits')
      hits.concat retrieved_hits
      @search_after = retrieved_hits.last['sort']
      break if retrieved_hits.count < 10_000
    end
  end

  private

  def process_raw_availability_history
    generator = Tools::EndpointsHistory::Generator.new(hits)
    endpoints_history = generator.to_endpoints_history

    mapper = Tools::EndpointsHistory::MapEndpointsToProviders.new(endpoints_history)
    @values = mapper.to_json
  end

  class AllAvailabilityHistory
    def initialize(search_after = nil)
      @search_after = search_after
    end

    def client
      @client ||= Elasticsearch::Client.new({host: 'watchdoge.entreprise.api.gouv.fr', log: false})
      @client.transport.reload_connections!
      @client
    end

    def execute
      client.search body: query
    end

    def query
      query_hash.merge({'search_after' => @search_after}).compact.to_json
    end

    def query_hash
      JSON.parse(query_basic_definition)
    end

    def query_basic_definition
      File.read(File.join('app', 'data', 'queries', query_name + '.json'))
    end

    def query_name
      'availability_history'
    end
  end

end
