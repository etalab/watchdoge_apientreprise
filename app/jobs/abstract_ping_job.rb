class AbstractPingJob < ApplicationJob
  include HTTParty

  def perform
    endpoints.each do |endpoint|
      ping = perform_ping(endpoint)
      yield ping if block_given?
    end
  end

  # rubocop:disable MethodLength
  def perform_ping(endpoint)
    http_response = get_http_response(endpoint)

    PingStatus.new(
      name: endpoint.name,
      http_response: http_response
    )
  end

  protected

  def request_url(endpoint)
    fail 'should implement request_url'
  end

  def endpoints
    fail 'should implement endpoints'
  end

  private

  def get_http_response(endpoint)
    self.class.get(request_url(endpoint))
  end
end
