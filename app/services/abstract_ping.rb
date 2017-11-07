class AbstractPing
  include HTTParty

  def initialize(hash = nil)
    return if hash.nil?
    hash.symbolize_keys!
    @period = hash.dig(:period)
  end

  def worker
    Tools::PingWorker.new
  end

  def perform
    worker.run(endpoints) do |endpoint|
      ping = perform_ping(endpoint)
      yield ping, endpoint if block_given?
    end
  end

  # rubocop:disable MethodLength
  def perform_ping(endpoint)
    @endpoint = endpoint
    ping = PingStatus.new(
      name: @endpoint.fullname,
      url: endpoint_url,
      http_response: get_http_response
    )

    send_notification(ping)

    ping
  end

  protected

  def endpoint_url
    fail 'should implement endpoint_url'
  end

  private

  def send_notification(ping)
    if (ping.status != 'up')
      PingMailer.ping(ping, @endpoint).deliver_now
    end
  end

  def endpoints
    Tools::EndpointFactory.new('apie').load_all.map { |ep|
      if (@period.nil? || ep.period == @period) && ep.api_version == self.class::API_VERSION
        ep
      end
    }.compact
  end

  def get_http_response
    self.class.get(endpoint_url)
  end
end
