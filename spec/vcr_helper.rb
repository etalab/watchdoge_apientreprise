VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri] } # TODO: add :body
  # c.default_cassette_options = { record: :new_episodes, allow_playback_repeats: true, match_requests_on: [:method, :uri, :body] }

  c.filter_sensitive_data('<APIE_TOKEN>') { Rails.application.config_for(:secrets) ['apie_token'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI_NEW>') { Rails.application.config_for(:secrets) ['apie_base_uri_new'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI_OLD>') { Rails.application.config_for(:secrets) ['apie_base_uri_old'].to_s }
end
