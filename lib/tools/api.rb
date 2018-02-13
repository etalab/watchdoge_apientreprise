class Tools::API
  def initialize(api_name:, api_version:)
    @api_name = api_name
    @api_version = api_version
  end

  def base_url
    case @api_name
    when 'apie'
      apie_base_url
    when 'sirene'
      Rails.application.config_for(:secrets)['sirene_base_uri']
    else
      raise "provider:#{@api_name} unsupported" # TODO: Sentry/Raven
    end
  end

  def token
    # else returns nil (important!)
    return nil unless @api_name == 'apie'

    if @api_version == 2
      Rails.application.config_for(:secrets)['apie_jwt_token']
    elsif @api_version == 1
      Rails.application.config_for(:secrets)['apie_bdd_token']
    end
  end

  private

  def apie_base_url
    case @api_version
    when 1
      Rails.application.config_for(:secrets)['apie_base_uri_old']
    when 2
      Rails.application.config_for(:secrets)['apie_base_uri_new']
    else
      raise "api_version:#{@api_version} unsupported!" # TODO: Sentry/Raven
    end
  end
end
