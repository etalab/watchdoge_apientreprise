class Endpoints::EtablissementsSuccesseur < Endpoint
  def initialize
    super
    @name = 'etablissements_successeur'
    @provider = 'insee'
    @api_version = 2
    @api_name = 'apie'
    @period = 60
    @parameter = '78414518700133'
    @options = { recipient: 'SGMAP', context: 'Ping' }
    @specific_url = endpoint_specific_url
  end

  private

  def endpoint_specific_url
    "/v2/etablissements/#{@parameter}/successeur?token=#{apie_token}&#{@options.to_param}"
  end

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
