VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  #c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri body] }
  c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri], record: :new_episodes }

  c.filter_sensitive_data('<APIE_TOKEN>') { Rails.application.config_for(:secrets)['apie_jwt_token'].to_s }
  c.filter_sensitive_data('<APIE_TOKEN>') { Rails.application.config_for(:secrets)['apie_bdd_token'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI_NEW>') { Rails.application.config_for(:secrets)['apie_base_uri_new'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI_OLD>') { Rails.application.config_for(:secrets)['apie_base_uri_old'].to_s }
end
