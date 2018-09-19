require 'net/http'

class Endpoint < ApplicationRecord
  extend Forwardable
  REDIRECT_LIMIT = 3

  validates :uname, presence: true, uniqueness: true
  validates :name, presence: true
  validates :api_name, presence: true
  validates :api_version, numericality: { only_integer: true }
  validates :provider, presence: true
  validates :ping_period, numericality: { only_integer: true }
  validates :http_path, presence: true

  validate :http_query_nil_or_json_string

  delegate %i[token] => :tool_api

  def http_response
    attempt_to_catch_net_http_errors do
      @http_response ||= fetch_with_redirection(uri)
    end
  end

  def uri
    URI(tool_api.base_url + http_path + http_params)
  end

  private

  # rubocop:disable Lint/ShadowedException
  def attempt_to_catch_net_http_errors
    # https://stackoverflow.com/questions/5370697/what-s-the-best-way-to-handle-exceptions-from-nethttp
    yield
  rescue VCR::Errors::UnhandledHTTPRequestError # for developpement
    raise $ERROR_INFO
  rescue Net::HTTPError, StandardError
    # TODO: Sentry/Raven
    Rails.logger.error "Something wrong happened when make the http request (#{$ERROR_INFO})"
  end
  # rubocop:enable Lint/ShadowedException

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

  def hash_options
    http_query.nil? ? {} : JSON.parse(http_query)
  end

  def http_query_nil_or_json_string
    errors.add(:http_query, 'must be nil or a JSON string') unless valid_http_query?
  end

  def valid_http_query?
    http_query.nil? || valid_json_query?(http_query)
  end

  def valid_json_query?(str)
    JSON.parse(str)
  rescue JSON::ParserError
    false
  end
end
