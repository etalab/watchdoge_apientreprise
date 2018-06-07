VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.configure_rspec_metadata!
  c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri body] }
  # c.default_cassette_options = { allow_playback_repeats: true, match_requests_on: %i[method uri body], record: :new_episodes }

  # one secret = one <FILTERED_VALUE> VCR fails
  c.filter_sensitive_data('<APIE_JWT_TOKEN>') { Rails.application.config_for(:secrets)['apie_jwt_token'].to_s }
  c.filter_sensitive_data('<APIE_BDD_TOKEN>') { Rails.application.config_for(:secrets)['apie_bdd_token'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI_NEW>') { Rails.application.config_for(:secrets)['apie_base_uri_new'].to_s }
  c.filter_sensitive_data('<APIE_BASE_URI_OLD>') { Rails.application.config_for(:secrets)['apie_base_uri_old'].to_s }

  # VCR_REGEN: filter jti param so we can easly stub data
  elk_search_uri = 'http://217.182.164.215:9200/_search'
  c.before_record do |interaction|
    if interaction.request.uri == elk_search_uri
      interaction.request.body.gsub!(/[a-zA-Z0-9]{8}-([a-zA-Z0-9]{4}-){3}[a-zA-Z0-9]{12}/, '<PRODUCTION_JTI>')
    end
  end

  c.before_playback do |interaction|
    if interaction.request.uri == elk_search_uri
      interaction.request.body.gsub!('<PRODUCTION_JTI>', JwtHelper.valid_jti)
    end
  end
end
