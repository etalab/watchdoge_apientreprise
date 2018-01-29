require 'forwardable'

class EndpointPingResult
  extend Forwardable
  delegate %i[uname name api_version http_path provider] => :endpoint
  attr_reader :endpoint, :code, :timestamp, :provider_name, :fallback_used

  def initialize(source)
    @endpoint = Endpoint.find_by_http_path source['path']
    @code = source['status']
    @timestamp = source['@timestamp']
    @provider_name = source.dig('response', 'provider_name')
    @fallback_used = source.dig('response', 'fallback_used')
  end

  def to_json
    {
      uname: endpoint.uname,
      name: endpoint.name,
      api_version: endpoint.api_version,
      provider: endpoint.provider,
      code: code,
      timestamp: timestamp,
      provider_name: provider_name,
      fallback_used: fallback_used
    }
  end
end
