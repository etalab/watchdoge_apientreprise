class Endpoints::LiassesFiscalesDGFIPDictionnaire < Endpoint
  def initialize
    super
    @name = 'liasses_fiscales_dgfip_dictionnaire'
    @provider = 'dgfip'
    @api_version = 2
    @api_name = 'apie'
    @period = 60
    @parameter = nil
    @options = { recipient: 'SGMAP', context: 'Ping' }
    @specific_url = endpoint_specific_url
  end

  private

  def endpoint_specific_url
    "/v2/liasses_fiscales_dgfip/2016/dictionnaire/?token=#{apie_token}&#{@options.to_param}"
  end

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
