class PingAPIEOnV1 < AbstractPing

  API_VERSION = 1
  base_uri Rails.application.config_for(:secrets)['apie_base_uri']

  protected

  def endpoint_url
    url = build_url
    sanitize url
  end

  private

  def build_url
    url = "/v1/#{@endpoint.sub_name}/#{@endpoint.name}/#{@endpoint.parameter}"
    parameters = "?token=#{apie_token}&#{@endpoint.options.to_param}"

    url + parameters
  end

  def sanitize(url)
    url.gsub!(%r{/+}, '/')
  end

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
