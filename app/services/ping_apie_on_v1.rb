class PingAPIEOnV1 < AbstractPing
  SERVICE_NAME  = 'apie'.freeze
  APIE_BASE_URI = Rails.application.config_for(:secrets)['apie_base_uri_old']
  APIE_TOKEN    = Rails.application.config_for(:secrets)['apie_token']
  API_VERSION   = 1

  protected

  def endpoint_url
    url = build_url
    sanitize url
  end

  private

  def build_url
    url = "/v1/#{@endpoint.sub_name}/#{@endpoint.name}/#{@endpoint.parameter}"
    parameters = "?token=#{APIE_TOKEN}&#{@endpoint.options.to_param}"

    url + parameters
  end

  def sanitize(url)
    url.gsub!(%r{/+}, '/')
  end
end
