class PingAPIEOnV2 < AbstractPing

  API_VERSION = 2
  base_uri Rails.application.config_for(:secrets)['apie_base_uri']

  protected

  def endpoint_url
    @endpoint.custom_url || build_url
  end

  private

  def build_url
    "/v2/#{@endpoint.name}/#{@endpoint.parameter}?token=#{apie_token}&#{@endpoint.options.to_param}"
  end

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
