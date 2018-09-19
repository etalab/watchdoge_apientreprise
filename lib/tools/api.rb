class Tools::API
  def initialize(api_name:, api_version:)
    @api_name = api_name
    @api_version = api_version
  end

  def base_url
    case @api_name
    when 'apie'
      apie_base_url
    when 'sirene', 'rna'
      Rails.application.config_for(:secrets)['sirene_base_uri']
    else
      raise "provider:#{@api_name} unsupported" # TODO: Sentry/Raven
    end
  end

  def token
    # else returns nil (important!)
    return nil unless @api_name == 'apie'

    if [2, 3].include?(@api_version)
      Rails.application.config_for(:secrets)['apie_jwt_token']
    end
  end

  private

  def apie_base_url
    case @api_version
    when 2, 3
      Rails.application.config_for(:secrets)['apie_base_uri']
    else
      raise "api_version:#{@api_version} unsupported!" # TODO: Sentry/Raven
    end
  end
end
