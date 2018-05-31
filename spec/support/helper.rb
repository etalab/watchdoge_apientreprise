def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end

def sorted_fake_calls(size: 10, oldest_timestamp: 8.days)
  endpoint_factory = EndpointFactory.new
  fake_calls = []
  size.times do
    timestamp = time_rand(Time.zone.now - oldest_timestamp)
    source = fake_elk_source(endpoint_factory.endpoints.sample, timestamp)
    fake_calls << CallResult.new(source, endpoint_factory)
  end

  fake_calls.sort_by(&:timestamp)
end

def fake_elk_source(endpoint, timestamp)
  {
    'path': endpoint.http_path,
    'status': %w[200 206 400 404 500 501].sample,
    '@timestamp': timestamp.to_s,
    'parameters': { context: 'Ping', recipient: 'SGMAP', siret: '41816609600069', token: '[FILTERED]' },
    'response': {
      'provider_name': endpoint.provider,
      'fallback_used': [true, false].sample
    }
  }.stringify_keys
end

def time_rand(from = 0.0, to = Time.zone.now)
  Time.zone.at(from + rand * (to.to_f - from.to_f))
end

def stub_jwt_usage_request
  stub_request(:get, /(\d{3}\.?){4}:9200/).to_return(
    status: 200,
    body: jwt_usage_stubbed_response,
    headers: { 'Content-Type': 'application/json; charset=UTF-8' }
  )
end

def jwt_usage_stubbed_response
  File.read('spec/support/payload_files/jwt_usage_elk_response.json')
end
