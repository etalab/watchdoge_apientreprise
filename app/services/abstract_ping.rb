class AbstractPing
  def initialize(hash = nil)
    return if hash.nil?
    hash.symbolize_keys!

    @period = hash.dig(:period)
  end

  def perform
    worker.run(endpoints) do |endpoint|
      ping = perform_ping(endpoint)
      yield ping, endpoint if block_given?
    end
  end

  def perform_ping(endpoint)
    @endpoint = endpoint

    ping = execute_ping
    send_notification(ping)

    ping
  end

  protected

  def endpoint_url
    fail 'should implement endpoint_url'
  end

  private

  # rubocop:disable Naming/AccessorMethodName
  def get_http_response
    HTTParty.get(self.class::APIE_BASE_URI + endpoint_url)
  end

  def worker
    Tools::PingWorker.new
  end

  def send_notification(ping)
    last_report = PingReport.get_latest_where(
      service_name: @endpoint.api_name,
      name: @endpoint.name,
      sub_name: @endpoint.sub_name,
      api_version: @endpoint.api_version)

    last_report.notify_new_ping(ping.code, Time.now)

    return unless last_report.has_changed?
    PingMailer.ping(last_report).deliver_now
  end

  def execute_ping
    PingStatus.new(
      name: @endpoint.full_name,
      url: endpoint_url,
      http_response: get_http_response
    )
  end

  def endpoints
    filter all_endpoints
  end

  def filter(endpoints)
    endpoints.map do |ep|
      ep if right_period?(ep) && right_version?(ep)
    end.compact
  end

  def all_endpoints
    Tools::EndpointFactory.new(self.class::SERVICE_NAME).load_all
  end

  def right_period?(endpoint)
    @period.nil? || endpoint.period == @period
  end

  def right_version?(endpoint)
    endpoint.api_version == self.class::API_VERSION
  end
end
