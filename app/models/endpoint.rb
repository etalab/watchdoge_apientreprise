class Endpoint < ApplicationRecord
  validates :uname, presence: true
  validates :name, presence: true
  validates :api_name, presence: true
  validates :api_version, numericality: { only_integer: true }
  validates :provider, presence: true
  validates :ping_period, numericality: { only_integer: true }
  validates :ping_url, presence: true

  validates_uniqueness_of :uname
  validate :json_options_nil_or_json_string

  def http_response
    Net::HTTP.get_response(uri)
  end

  def uri
    URI(base_url + ping_url + http_params)
  end

  private

  def http_params
    if api_name == 'apie'
      '?' + {token: token}.merge(hash_options).to_param
    else
      ''
    end
  end

  def hash_options
    json_options.nil? ? {} : JSON.parse(json_options)
  end

  def token
    if api_name == 'apie'
      Rails.application.config_for(:secrets)['apie_token']
    end
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
    unless json_options.nil? || json_options.valid_json?
      errors.add(:json_options, 'must be nil or a JSON string')
    end
  end
end
