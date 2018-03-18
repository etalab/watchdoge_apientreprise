def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end

def valid_jti
  'b5be66cc-d182-420c-b0a7-a763b02c9e13'
end

def fake_calls(size: 10, oldest_timestamp: 8.days)
  endpoint_factory = EndpointFactory.new
  fake_calls = []
  size.times do
    fake_calls << CallCharacteristics.new(fake_elk_source(endpoint_factory.endpoints.sample, oldest_timestamp), endpoint_factory)
  end

  fake_calls
end

def fake_elk_source(endpoint, oldtest_timestamp)
  {
    'path': endpoint.http_path,
    'status': %w[200 206 400 404 500 501].sample,
    '@timestamp': time_rand(Time.zone.now - oldtest_timestamp),
    'response': {
      'provider_name': endpoint.provider,
      'fallback_used': [true, false].sample
    }
  }.stringify_keys
end

def time_rand(from = 0.0, to = Time.zone.now)
  Time.zone.at(from + rand * (to.to_f - from.to_f))
end