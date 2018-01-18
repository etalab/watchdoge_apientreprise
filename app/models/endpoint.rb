require 'net/http'

class Endpoint < ApplicationRecord
  REDIRECT_LIMIT = 3

  validates :uname, presence: true, uniqueness: true
  validates :name, presence: true
  validates :api_name, presence: true
  validates :api_version, numericality: { only_integer: true }
  validates :provider, presence: true
  validates :ping_period, numericality: { only_integer: true }
  validates :http_path, presence: true

  validate :http_query_nil_or_json_string

  def http_response
    @http_response ||= fetch_with_redirection(uri)
  end

  def uri
    URI(base_url + http_path + http_params)
  end

  def self.find_by_http_path(url)
    perfect_match_endpoint = Endpoint.find_by(http_path: url)
    return perfect_match_endpoint unless perfect_match_endpoint.nil?

    find_by_http_path_regexp(url)

    # TODO REFACTOR choisir entre self et find_by
    #Endpoint.find_by(http_path: url) || find_by_http_path_regexp(url)
  end

  private

  private_class_method def self.find_by_http_path_regexp(url)
    # replace siren/siret (2+ digits or RNA id W000000000) with regexp /.+/ : siret/siren parameters in ELK can be different from those in YAML file
    regexp_url = url.gsub(/[A-Z]?\d{2,}/, '.+')
    # Warning '~' is specific to PGSQL !
    endpoint = Endpoint.find_by('http_path ~ ?', regexp_url)
    return endpoint unless endpoint.nil?

    # TODO: Sentry /Raven
    Rails.logger.error "fail to find Endpoint with url: #{url}"
  end

  def fetch_with_redirection(location, redirection_follow_count=0)
    response = Net::HTTP.get_response(location)

    if response.kind_of? Net::HTTPRedirection
      return response if redirection_follow_count == REDIRECT_LIMIT

      redirect_location = URI(response['location'])
      fetch_with_redirection(redirect_location, redirection_follow_count + 1)
    else
      response
    end
  end

  def http_params
    send("#{api_name}_http_params")
  rescue NoMethodError
    ''
  end

  def apie_http_params
    '?' + { token: token }.merge(hash_options).to_param
  end

  def hash_options
    http_query.nil? ? {} : JSON.parse(http_query)
  end

  def token
    Rails.application.config_for(:secrets)['apie_token'] if api_name == 'apie'
  end

  def base_url
    case api_name
    when 'apie'
      apie_base_url
    when 'sirene'
      Rails.application.config_for(:secrets)['sirene_base_uri']
    else
      raise "provider:#{provider} unsupported" # TODO: Sentry/Raven
    end
  end

  def apie_base_url
    case api_version
    when 1
      Rails.application.config_for(:secrets)['apie_base_uri_old']
    when 2
      Rails.application.config_for(:secrets)['apie_base_uri_new']
    else
      raise "api_version:#{api_version} unsupported!" # TODO: Sentry/Raven
    end
  end

  def http_query_nil_or_json_string
    errors.add(:http_query, 'must be nil or a JSON string') unless valid_http_query?
  end

  def valid_http_query?
    http_query.nil? || valid_json_query?(http_query)
  end

  def valid_json_query?(s)
    JSON.parse(s)
  rescue JSON::ParserError
    false
  end
end
