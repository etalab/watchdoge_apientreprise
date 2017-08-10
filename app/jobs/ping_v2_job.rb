class PingV2Job < ApplicationJob
  include HTTParty

  attr_reader :pings

  base_uri Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']

  def initialize
    super
    @pings = []
  end

  def perform
    @pings.clear

    endpoints_v2.each do |endpoint|
      ping = perform_ping(endpoint)

      if ping.valid?
        yield ping if block_given?
      end
    end
  end

  # rubocop:disable MethodLength
  def perform_ping(endpoint)
    http_response = get_http_response(endpoint)

    ping = PingStatus.new(
      name: endpoint.name,
      api_version: 2,
      status: get_service_status(http_response),
      date: DateTime.now,
      environment: Rails.env,
      http_response: http_response
    )

    after_request_check(ping)

    ping
  end

  private

  def after_request_check(ping)
    if ping.valid?
      @pings << ping
      Tools::PingReaderWriter.new.write(ping) # this file is not used...
      log(ping)
    else
      Rails.logger.error "Fail to write PingStatus(#{ping.name}) it's invalid (#{ping.errors.messages})"
    end
  end

  def get_service_status(http_response)
    http_response.code == 200 ? 'up' : 'down'
  end

  def get_http_response(endpoint)
    self.class.get(request_url(endpoint))
  end

  def request_url(endpoint)
    "/v2/#{endpoint.name}/#{endpoint.parameter}?token=#{apie_token}&#{endpoint.options.to_param}"
  end

  def log(ping)
    @logger.info(
      endpoint: ping.name,
      status: ping.status,
      date: ping.date,
      api_version: ping.api_version,
      environment: ping.environment
    )
  end

  def apie_token
    Rails.application.config_for(:watchdoge_secrets)['apie_token']
  end

  def endpoints_v2
    Tools::EndpointFactory.new.load_all
  end
end
