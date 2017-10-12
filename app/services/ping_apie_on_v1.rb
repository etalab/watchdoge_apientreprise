class PingAPIEOnV1 < AbstractPing

  base_uri Rails.application.config_for(:secrets)['apie_base_uri']

  protected

  def request_url(endpoint)
    url = "/v1/#{endpoint.sub_name}/#{endpoint.name}/#{endpoint.parameter}"
    parameters = "?token=#{apie_token}&#{endpoint.options.to_param}"
    (url + parameters).gsub!(%r{/+}, '/')
  end

  def endpoints
    Tools::EndpointFactory.new('apie').load_all.map{ |ep| ep if ep.api_version == 1 }.compact
  end

  private

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
