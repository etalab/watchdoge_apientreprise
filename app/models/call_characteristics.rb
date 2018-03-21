require 'forwardable'

class CallCharacteristics
  extend Forwardable
  delegate %i[uname name api_version http_path provider] => :endpoint
  attr_reader :endpoint, :code, :timestamp, :params, :provider_name, :fallback_used

  API_NAME = 'apie'.freeze

  def initialize(source, endpoint_factory = EndpointFactory.new)
    @endpoint = endpoint_factory.find_endpoint_by_http_path(http_path: source['path'], api_name: API_NAME)
    @code = source['status']
    @timestamp = source['@timestamp']
    @params = source['parameters'].symbolize_keys.delete_if { |key| key == :token }.map { |k, v| { "#{k}": v } }
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
