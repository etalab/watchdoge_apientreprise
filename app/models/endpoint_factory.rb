# Flyweight factory
class EndpointFactory
  attr_reader :endpoints

  def initialize
    # rubocop:disable Rails/FindEach
    @endpoints = Endpoint.all.each(&:freeze)
    # rubocop:enable Rails/FindEach
  end

  def find_endpoint_by_uname(uname)
    @endpoints.find do |endpoint|
      return endpoint if endpoint.uname == uname
    end

    # TODO: Sentry /Raven
    Rails.logger.error "fail to find Endpoint with uname: #{uname}"
    nil
  end

  def find_endpoint_by_http_path(http_path:, api_name:)
    quick_perfect_match_endpoint(http_path, api_name) || slow_regexp_match_endpoint(http_path, api_name)
  end

  private

  def quick_perfect_match_endpoint(http_path, api_name)
    @endpoints.find do |endpoint|
      return endpoint if endpoint.http_path == http_path && endpoint.api_name == api_name
    end
  end

  def slow_regexp_match_endpoint(http_path, api_name)
    @endpoints.find do |endpoint|
      return endpoint if endpoint.http_path.match?(regexp_http_path(http_path)) && endpoint.api_name == api_name
    end

    # TODO: Sentry /Raven
    Rails.logger.error "fail to find Endpoint with http_path: #{http_path}"
    nil
  end

  def regexp_http_path(http_path)
    # replace siren/siret (2+ digits or RNA id W000000000 - caledonia also like W9N1004065)
    # with regexp /.+/ : siret/siren parameters in ELK can be different from those in YAML file
    Regexp.new(http_path.gsub(/[A-Z]?[0-9A-Z]{2,}/, '[^\/]+') + '$')
  end
end
