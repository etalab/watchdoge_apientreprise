class PingAPIEOnV2 < AbstractPing

  base_uri Rails.application.config_for(:secrets)['apie_base_uri']

  protected

  def request_url(endpoint)
    endpoint.custom_url || "/v2/#{endpoint.name}/#{endpoint.parameter}?token=#{apie_token}&#{endpoint.options.to_param}"
  end

  def endpoints_conditions(endpoint)
    endpoint.api_version == 2
  end

  private

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
