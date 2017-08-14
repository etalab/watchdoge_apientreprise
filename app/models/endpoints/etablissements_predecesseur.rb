class Endpoints::EtablissementsPredecesseur < Endpoint
  def initialize
    super
    @name = 'etablissements_predecesseur'
    @api_version = 2
    @api_name = 'apie'
    @parameter = '41816609600069'
    @options = { recipient: 'SGMAP', context: 'Ping' }
    @custom_url = endpoint_custom_url
  end

  private

  def endpoint_custom_url
    "/v2/etablissements/#{@parameter}/predecesseur?token=#{apie_token}&#{@options.to_param}"
  end

  def apie_token
    Rails.application.config_for(:watchdoge_secrets)['apie_token']
  end
end
