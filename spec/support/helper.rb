def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end

def valid_jti
  'b5be66cc-d182-420c-b0a7-a763b02c9e13'
end

def sorted_fake_calls(size: 10, oldest_timestamp: 8.days)
  endpoint_factory = EndpointFactory.new
  fake_calls = []
  size.times do
    timestamp = time_rand(Time.zone.now - oldest_timestamp)
    source = fake_elk_source(endpoint_factory.endpoints.sample, timestamp)
    fake_calls << CallCharacteristics.new(source, endpoint_factory)
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