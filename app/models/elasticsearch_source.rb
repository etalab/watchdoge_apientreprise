require 'forwardable'

class ElasticsearchSource
  extend Forwardable
  delegate %i[uname name api_version ping_url provider] => :endpoint
  attr_reader :endpoint, :code, :timestamp

  def initialize(source)
    @endpoint = Endpoint.find_by_ping_url source['path']
    @code = source['status']
    @timestamp = source['@timestamp']
  end

  def to_json
    {
      uname: endpoint.uname,
      name: endpoint.name,
      api_version: endpoint.api_version,
      provider: endpoint.provider,
      code: code,
      timestamp: timestamp
    }
  end
end
