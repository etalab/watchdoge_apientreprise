class PingMailer < ApplicationMailer
  default from: Rails.application.config_for(:secrets)['ping_email_sender']
  layout 'mailer'

  def ping(endpoint, ping_report)
    @endpoint = endpoint
    @ping_report = ping_report
    mail(to: to, subject: subject)
  end

  private

  def to
    Rails.application.config_for(:secrets)['ping_email_recipient']
  end

  def subject
    "[Watchdoge] V#{@endpoint.api_version} #{@endpoint.name} #{@ping_report.status.upcase} à #{Time.now.strftime('%kh%M')}"
  end
end
