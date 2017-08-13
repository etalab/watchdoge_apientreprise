class PingAPIEOnV2Job < AbstractPingJob

  base_uri Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']

  protected

  def service_name
    'apie'
  end

  def request_url(endpoint)
    "/v2/#{endpoint.name}/#{endpoint.parameter}?token=#{apie_token}&#{endpoint.options.to_param}"
  end

  def endpoints
    Tools::EndpointFactory.new(service_name).load_all
  end

  private

  def apie_token
    Rails.application.config_for(:watchdoge_secrets)['apie_token']
  end
end
