VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.default_cassette_options = { allow_playback_repeats: true }

  c.filter_sensitive_data('<APIE_TOKEN>') { Rails.application.config_for(:watchdoge_secrets) ['apie_token'].to_s }
end
