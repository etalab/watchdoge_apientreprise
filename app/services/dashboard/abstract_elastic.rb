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
    rescue
      @success = false
    end

    self
  end

  def get_raw_response(query_name)
    query = load_query query_name
    @raw_response = @client.search body: query
  end

  def load_query(query_name)
    File.read(File.join('app', 'data', 'queries', query_name + '.json'))
  end

  def ping_infos_from_elasticsearch(raw_data)
    version, name, subname = raw_data['controller'].split('/').slice(1, 4)
    fullname = name + (subname || '') + version
    name = name.gsub(/_/, ' ').capitalize
    status = raw_data['status']
    timestamp = raw_data['@timestamp']

    {
      name: name,
      subname: subname,
      fullname: fullname,
      version: version,
      code: status,
      timestamp: timestamp
    }
  end
end
