require 'net/http'

class Endpoint < ApplicationRecord
  REDIRECT_LIMIT = 3

  validates :uname, presence: true, uniqueness: true
  validates :name, presence: true
  validates :api_name, presence: true
  validates :api_version, numericality: { only_integer: true }
  validates :provider, presence: true
  validates :ping_period, numericality: { only_integer: true }
  validates :ping_url, presence: true

  validate :json_options_nil_or_json_string

  def http_response
    fetch_with_redirection(uri, REDIRECT_LIMIT)
  end

  def uri
    URI(base_url + ping_url + http_params)
  end

  private

  def fetch_with_redirection(location, redirect_limit)
    response = Net::HTTP.get_response(location)

    if redirect_limit.zero?
      response
    else
      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        fetch_with_redirection(URI(location), redirect_limit - 1)
      else
        response.value
      end
    end
  end

  def http_params
    api_name == 'apie' ? apie_http_params : ''
  end

  def apie_http_params
    '?' + { token: token }.merge(hash_options).to_param
  end

  def hash_options
    json_options.nil? ? {} : JSON.parse(json_options)
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
      raise "provider:#{provider} unsupported" # TODO: raven
    end
  end

  def apie_base_url
    case api_version
    when 1
      Rails.application.config_for(:secrets)['apie_base_uri_old']
    when 2
      Rails.application.config_for(:secrets)['apie_base_uri_new']
    else
      raise "api_version:#{api_version} unsupported!" # TODO: raven
    end
  end

  def json_options_nil_or_json_string
    errors.add(:json_options, 'must be nil or a JSON string') unless valid_json_options?
  end

  def valid_json_options?
    json_options.nil? || json_options.valid_json?
  end
end
