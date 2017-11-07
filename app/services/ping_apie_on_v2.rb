class PingAPIEOnV2 < AbstractPing

  API_VERSION = 2

  protected

  def endpoint_url
    @endpoint.specific_url || build_url
  end

  private

  def build_url
    "/v2/#{@endpoint.name}/#{@endpoint.parameter}?token=#{APIE_TOKEN}&#{@endpoint.options.to_param}"
  end
end
