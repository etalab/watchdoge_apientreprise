class PingSirene < AbstractPing
  SERVICE_NAME  = 'sirene'
  APIE_BASE_URI = Rails.application.config_for(:secrets)['sirene_base_uri']
  API_VERSION   = 1

  protected

  def endpoint_url
    "/?#{@endpoint.options.to_param}"
  end
end
