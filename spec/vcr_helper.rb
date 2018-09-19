VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri body] }
  # c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri body], record: :new_episodes }

  # one secret = one <FILTERED_VALUE> VCR fails
  c.filter_sensitive_data('<APIE_JWT_TOKEN>')  { Rails.application.config_for(:secrets)['apie_jwt_token'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI>')   { Rails.application.config_for(:secrets)['apie_base_uri'].to_s }
  c.filter_sensitive_data('<SIRENE_BASE_URI>') { Rails.application.config_for(:secrets)['sirene_base_uri'].to_s }
end
