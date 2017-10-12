class PingAPIEOnV2 < AbstractPing

  base_uri Rails.application.config_for(:secrets)['apie_base_uri']

  protected

  def request_url(endpoint)
    endpoint.custom_url || "/v2/#{endpoint.name}/#{endpoint.parameter}?token=#{apie_token}&#{endpoint.options.to_param}"
  end

  def endpoints
    Tools::EndpointFactory.new('apie').load_all.map { |ep| ep if ep.api_version == 2 }.compact
  end

  private

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
