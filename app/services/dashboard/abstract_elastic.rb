class Dashboard::AbstractElastic
  def initialize
    @client = Elasticsearch::Client.new({host: 'watchdoge.entreprise.api.gouv.fr', log: false})
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

  def process_query
    begin
      yield
    end

    self
  end

  def get_raw_response(query_name)
    query = load_query query_name

    begin
      @raw_response = @client.search body: query
    rescue
      @success = false
    end
  end

  def load_query(query_name)
    File.read(File.join('app', 'data', 'queries', query_name + '.json'))
  end

  def ping_infos_from_elasticsearch(raw_data)
    api_version, name, sub_name = raw_data['controller'].split('/').slice(1, 4)
    api_version = api_version.gsub('v', '').to_i
    status = raw_data['status']
    timestamp = raw_data['@timestamp']

    # For liasse_fiscales_dgfip dictionnaire/complete/declaration
    if name =~ /liasses_fiscales_dgfip/ && api_version == 2
      sub_name = raw_data['action']
    end

    {
      name: name,
      sub_name: sub_name,
      api_version: api_version,
      code: status,
      timestamp: timestamp
    }
  end
end
