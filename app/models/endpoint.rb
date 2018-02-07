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
    URI(tool_api.base_url + http_path + http_params)
  end

  def self.find_by_http_path(url)
    perfect_match_endpoint = Endpoint.find_by(http_path: url)
    return perfect_match_endpoint unless perfect_match_endpoint.nil?

    find_by_http_path_regexp(url)

    # TODO: REFACTOR choisir entre self et find_by
    # Endpoint.find_by(http_path: url) || find_by_http_path_regexp(url)
  end

  private

  private_class_method def self.find_by_http_path_regexp(url)
    # replace siren/siret (2+ digits or RNA id W000000000 - caledonia also like W9N1004065)
    # with regexp /.+/ : siret/siren parameters in ELK can be different from those in YAML file
    regexp_url = url.gsub(/[A-Z]?[0-9A-Z]{2,}/, '.+')
    # Warning '~' is specific to PGSQL !
    endpoint = Endpoint.find_by('http_path ~ ?', regexp_url)
    return endpoint unless endpoint.nil?

    # TODO: Sentry /Raven
    Rails.logger.error "fail to find Endpoint with url: #{url}"
  end

  def fetch_with_redirection(location, redirection_follow_count = 0)
    response = Net::HTTP.get_response(location)

    if response.is_a? Net::HTTPRedirection
      return response if redirection_follow_count == REDIRECT_LIMIT

      redirect_location = URI(response['location'])
      fetch_with_redirection(redirect_location, redirection_follow_count + 1)
    else
      response
    end
  end

  def tool_api
    @tool_api ||= Tools::API.new(api_name: api_name, api_version: api_version)
  end

  def http_params
    '?' + { token: token }.merge(hash_options).compact.to_param
  end

  def token
    tool_api.token
  end

  def hash_options
    http_query.nil? ? {} : JSON.parse(http_query)
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
