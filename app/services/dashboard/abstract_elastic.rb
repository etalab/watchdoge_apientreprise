class Dashboard::AbstractElastic
  def initialize
    @client = Elasticsearch::Client.new(host: 'watchdoge.entreprise.api.gouv.fr', log: false)
    @client.transport.reload_connections!
    @values = []
    @success = true
  end

  def results
    @values.as_json
  end

  def success?
    @success
  end

  protected

  def get_raw_response(query)
    begin
      @raw_response = @client.search body: query
    rescue
      @success = false
    end
  end

  def load_query(query_name)
    File.read(File.join('app', 'data', 'queries', query_name + '.json'))
  end
end
