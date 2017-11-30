class Endpoints::EtablissementsPredecesseur < Endpoint
  def initialize
    super
    @name = 'etablissements'
    @sub_name = 'predecesseur'
    @provider = 'insee'
    @api_version = 2
    @api_name = 'apie'
    @period = 60
    @parameter = '41816609600069'
    @options = { recipient: 'SGMAP', context: 'Ping' }
    @specific_url = endpoint_specific_url
  end

  private

  def endpoint_specific_url
    "/v2/etablissements/#{@parameter}/predecesseur?token=#{apie_token}&#{@options.to_param}"
  end

  def apie_token
    Rails.application.config_for(:secrets)['apie_token']
  end
end
