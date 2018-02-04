class PingWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(uname)
    @endpoint = Endpoint.find_by(uname: uname)
    ping_report.notify_changes(code_http)
    send_notification if ping_report.changed?
  end

  private

  def send_notification
    PingMailer.ping(@endpoint, ping_report).deliver_later
  end

  def ping_report
    @ping_report ||= PingReport.find_or_create_by(uname: @endpoint.uname)
  end

  def code_http
    @endpoint.http_response.code.to_i
  end
end
