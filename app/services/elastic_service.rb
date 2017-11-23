class ElasticService
  def initialize
    @client = Elasticsearch::Client.new({host: 'watchdoge.entreprise.api.gouv.fr', log: false})
    @client.transport.reload_connections!
    @values = []
    @success = true
  end

  def get_current_status
    process_query do
      get_raw_response current_status_query
      process_raw_current_status
    end
  end

  def results
    @values.as_json
  end

  def success?
    @success
  end

  private

  def process_query
    begin
      yield
    rescue
      @success = false
    end

    self
  end

  def get_raw_response(query)
    @raw_response = @client.search body: query
  end

  def current_status_query
    load_query 'current_status.json'
  end

  def load_query(filename)
    File.read(File.join('app', 'data', 'queries', filename))
  end

  def process_raw_current_status
    raw_endpoints = @raw_response.dig('aggregations', 'group_by_controller', 'buckets')
    raw_endpoints.each do |e|
      raw_infos = e.dig('agg_by_endpoint', 'hits', 'hits').first['_source']
      version, name, subname = raw_infos['controller'].split('/').slice(1, 4)
      name = name.gsub(/_/, ' ').capitalize
      status = raw_infos['status']
      timestamp = raw_infos['@timestamp']

      endpoint = {
        'name': name,
        'subname': subname,
        'version': version,
        'code': status,
        'timestamp': timestamp
      }

      @values << endpoint
    end
  end
end
